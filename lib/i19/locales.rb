# encoding: UTF-8
module I19
  class Locales
    include I19::Logging
    attr_accessor :config, :locales, :default_locale
    def initialize(options = {})
      @config = options.reverse_merge(I19.config)
      @locales = config.fetch(:locales, nil) || find_locales
      @default_locale = find_default_locale(config.fetch(:default_locale_code, nil))
    end

    def update(key)
      if key.value.present?
        if default_locale.has_key?(key)
          if default_locale.key_changes?(key)
            default_locale.update_key(key)
            locales_without_default.each{|locale| locale.mark_as_pending(key)}
            Event.new(level: Event::LEVEL[:warn], type: :update, data: key, message: 'Default Locale changed and it will get updated. All the other locales marked as pending')
          else
            mark_other_locales_as_peding_if_not_translated(key)
            Event.new(level: Event::LEVEL[:info], type: :nothing_changed, data: key, message: 'Default Locale didnt changed. All the other locales will be marked as pending if they dont already have a translation')
          end
        else
          default_locale.add_key(key)
          locales_without_default.each{ |locale| locale.mark_as_pending(key) }
          Event.new(level: Event::LEVEL[:success], type: :create, data: key, message: 'Creating new translatoin for the default locale. All the other locales marked as pending')
        end
      else #there is no default value for key
        if default_locale.has_key?(key)
          mark_other_locales_as_peding_if_not_translated(key, default_locale_translation: default_locale[key])
          Event.new(level: Event::LEVEL[:info], type: :nothing_changed, data: key, message: 'No default specified but default_locale has already a translation. All the other locales will be marked as pending if they dont already have a translation')
        else
          locales.each{ |locale| locale.mark_as_pending(key) }
          Event.new(level: Event::LEVEL[:error], type: :missing_translation, data: key, message: 'No default specified for new key, it will be marked as pending. All the other locales marked as pending')
        end
      end
    end

    def save!
      locales.each(&:save!)
    end

    private
    def mark_other_locales_as_peding_if_not_translated(key, *extra)
      locales_without_default.each do |locale|
        unless locale.has_key?(key) && !locale.pending?(key)
          locale.mark_as_pending(key, *extra)
        end
      end
    end

    def locales_without_default
      locales - Array(default_locale)
    end

    def find_locales
      Dir.glob(File.join(config[:locales_path], "*.yml")).map do |file_path|
        data = ::YAML.load(File.open(file_path)).with_indifferent_access
        language = data.keys.first
        Locale.new(language, data, file_path, config)
      end
    end

    def find_default_locale(code)
      return if code.nil?
      locales.find{ |locale| locale.language.to_sym == code.to_sym }
    end
  end

  class Locale
    PENDING_MESSAGE = "I19 TRANSLATION PENDING"
    attr_accessor :language, :data, :source_path, :pending_data, :config
    def self.from_file(file_path)
      data = ::YAML.load(File.open(file_path)).with_indifferent_access
      language = data.keys.first
      Locale.new(language, data, file_path)
    end

    def initialize(language, data, source_path, options = {})
      @config = options.reverse_merge(I19.config)
      @language, @data, @source_path = language, data.with_indifferent_access, source_path
      @data[@language] ||= {} #edge case where data could be empty like this: {en: nil}
      @pending_data = {@language => {}}.with_indifferent_access
    end

    def add_key(key)
      self[key.key]= key.value
    end

    def update_key(key)
      self[key.key]= key.value
    end

    def key_changes?(key)
      self[key] != key.value
    end

    def mark_as_pending(key, extra = {})
      _key   = key.key.to_s
      _value = key.value || extra.fetch(:default_locale_translation, nil) ||PENDING_MESSAGE
      deeply_store_hash(pending_data[language], _key, _value)
    end

    def pending_data?
      pending_data[language].present?
    end

    def pending?(key)
      key = key.respond_to?(:key) ? key.key.to_s : key.to_s
      deeply_find_hash(pending_data[language], key).present?
    end

    def find_key_for_translation(str)
      str = str.strip
      result = flat_data.select do |key, translation|
        translation.match(/#{str}/i) if translation.respond_to?(:match)
      end
      result.present? ? result : false
    end

    def [](key)
      key = key.respond_to?(:key) ? key.key.to_s : key.to_s
      deeply_find_hash(data[language], key)
    end

    def []=(key, value)
      key = key.respond_to?(:key) ? key.key.to_s : key.to_s
      deeply_store_hash(data[language], key, value)
    end

    def has_key?(key)
      self[key].present?
    end

    def save!(destination_path = source_path)
      # puts "saving #{source_path}"
      File.open(destination_path, 'w') {|f| f.write(dump( deeply_sort_hash(data) )) }
      if pending_data?
        pending_data_file_name = "#{config[:i19_missing_yaml_file_name]}.#{language}.yml"
        pending_data_file_path = File.join(config[:locales_path], pending_data_file_name)
        File.open(pending_data_file_path, 'w') {|f| f.write(dump( deeply_sort_hash(pending_data) )) }
      end
    end

    def destroy!
      # puts "destroying #{source_path}"
      FileUtils.rm_f(source_path)
    end

    private
    def deeply_store_hash(hash, key, value)
      keys = key.split(".")
      last_key = keys.pop
      result = keys.inject(hash) do |subtree, k|
        unless subtree.has_key?(k)
          subtree[k] = {}
        end
        subtree[k]
      end
      result[last_key] = value
    end

    def deeply_find_hash(hash, key)
      subtree = hash
      key.split(".").each do |subkey|
        subtree = subtree.fetch(subkey, {})
      end
      subtree
    end

    def deeply_sort_hash(object)
      return object unless object.is_a?(Hash)
      hash = Hash.new
      object.each { |k, v| hash[k] = deeply_sort_hash(v) }
      sorted = hash.sort { |a, b| a[0].to_s <=> b[0].to_s }
      hash.class[sorted]
    end

    def flat_data
      flat_hash(data)
    end

    # flat_hash converts:
    # {
    #     :a => {
    #        :b => {:c => 1, :d => 2},
    #        :e => 3,
    #     },
    #     :f => 4,
    # }
    # into:
    # {
    #     [:a, :b, :c] => 1,
    #     [:a, :b, :d] => 2,
    #     [:a, :e] => 3,
    #     [:f] => 4,
    # }
    # http://stackoverflow.com/a/23861946/159537
    def flat_hash(h,f=[],g={})
      return g.update({ f=>h }) unless h.is_a? Hash
      h.each { |k,r| flat_hash(r,f+[k],g) }
      g
    end

    # def save_in_missing_file
    #   missing_translations = YAML::load_file(missing_locale_file_path)
    #   numbers_of_keys = @keys.length
    #   current_key_idx = 1
    #   @keys.inject(missing_translations) do |hash, key|
    #     is_last_key = current_key_idx == numbers_of_keys
    #     key = key.to_s
    #     # binding.pry if key == "unexistant_key" && numbers_of_keys == 3
    #     # binding.pry if key == "nested" && numbers_of_keys == 3
    #     if is_last_key
    #       hash[key] = guess_best_translation
    #     else
    #       hash[key] = {} unless hash[key].is_a? Hash
    #       hash[key] = hash.fetch(key, nil) || {}
    #     end
    #     current_key_idx += 1
    #     hash[key]
    #   end
    #   File.open(missing_locale_file_path, 'w') {|f| f.write missing_translations.to_yaml }
    # end

    # @return [Hash] locale tree
    def parse(str, options)
      if YAML.method(:load).arity.abs == 2
        YAML.load(str, options || {})
      else
        # older jruby and rbx 2.2.7 do not accept options
        YAML.load(str)
      end
    end

    # @return [String]
    def dump(tree, options = {})
      # YAML.unescape(YAML.dump(tree))
      options.reverse_merge!({line_width: -1}) # avoids line wrapping
      tree.to_yaml(options)
    end
  end
end
