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
            log_warn "Default Locale changed: '#{key.key}' => '#{key.value}'"
            default_locale.update_key(key)
            # locales_without_default.each{|locale| locale.mark_as_pending(key)}
          else
            log_warn "Default Locale didnt changed: '#{key.key}'"
            # mark_other_locales_as_peding_if_not_translated(key)
          end
        else
          log_warn "Creating Locale: '#{key.key}' => '#{key.value}'"
          default_locale.add_key(key)
          # locales_without_default.each{ |locale| locale.mark_as_pending(key) }
        end
      else #there is no default value for key
        if default_locale.has_key?(key)
          log_warn "No default specified and default_locale has already a translation: '#{key.key}'"
          mark_other_locales_as_peding_if_not_translated(key)
        else
          log_warn "No default specified for new key: '#{key.key}'"
          # locales.each{ |locale| locale.mark_as_pending(key) }
        end
      end
    end

    def save!
      locales.each(&:save!)
    end

    private
    def mark_other_locales_as_peding_if_not_translated(key)
      locales_without_default.each do |locale|
        unless locale.has_key?(key) && !locale.pending?(key)
          locale.mark_as_pending(key)
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
        Locale.new(language, data, file_path)
      end
    end

    def find_default_locale(code)
      return if code.nil?
      locales.find{ |locale| locale.language.to_sym == code.to_sym }
    end
  end

  class Locale
    PENDING_MESSAGE = "I19 TRANSLATION PENDING"
    attr_accessor :language, :data, :source_path
    def self.from_file(file_path)
      data = ::YAML.load(File.open(file_path)).with_indifferent_access
      language = data.keys.first
      Locale.new(language, data, file_path)
    end

    def initialize(language, data, source_path)
      @language, @data, @source_path = language, data.with_indifferent_access, source_path
      @data[@language] ||= {} #edge case where data could be empty like this: {en: nil}
      @new_data = {}
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

    def mark_as_pending(key)
      # self[key] = "#{PENDING_MESSAGE} - #{key.value}"
    end

    def pending?(key)
      self[key].match(PENDING_MESSAGE)
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
      subtree = data[language]
      key.split(".").each do |subkey|
        subtree = subtree.fetch(subkey, {})
      end
      subtree
    end

    def []=(key, value)
      key = key.respond_to?(:key) ? key.key.to_s : key.to_s
      keys = key.split(".")
      last_key = keys.pop
      result = keys.inject(data[language]) do |subtree, k|
        unless subtree.has_key?(k)
          subtree[k] = {}
        end
        subtree[k]
      end
      result[last_key] = value
    end

    def has_key?(key)
      self[key].present?
    end

    def save!(destination_path = source_path)
      # puts "saving #{source_path}"
      File.open(destination_path, 'w') {|f| f.write(dump( deeply_sort_hash(data) )) }
    end

    def destroy!
      # puts "destroying #{source_path}"
      FileUtils.rm_f(source_path)
    end

    private
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
      tree.to_yaml(options)
    end
  end
end
