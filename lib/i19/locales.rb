module I19
  class Locales
    attr_accessor :config, :locales
    def initialize(options = {})
      @config = options.reverse_merge(I19.config)
      @locales = config.fetch(:locales, nil) || find_locales
      @default_locale = config.fetch(:default_locale, nil)
    end

    def update(key, options={})
      # TODO: check if default_locale changed if it did what do we wanna do with the other locales?
      locales.each do |locale|
        if locale.has_key?(key)
          has_changed = locale[key] != key.default
          puts "#{locale.language}.#{key.key} has_changed? = #{has_changed}"
        else
          locale.add_key(key)
        end
      end
    end

    private
    def find_locales
      Dir.glob(File.join(config[:locales_path], "*.yml")).map do |file_path|
        data = ::YAML.load(File.open(file_path)).with_indifferent_access
        language = data.keys.first
        Locale.new(language, data, file_path)
      end
    end
  end

  class Locale
    attr_accessor :language, :data, :source_path
    def initialize(language, data, source_path)
      @language, @data, @source_path = language, data.with_indifferent_access, source_path
      @new_data = {}
    end

    def add_key(key)
      puts "Locale[#{language}]: adding key #{key.key}"
    end

    def [](key)
      key = key.respond_to?(:key) ? key.key.to_s : key.to_s
      subtree = data[language]
      key.split(".").each do |subkey|
        subtree = subtree.fetch(subkey, {})
      end
      subtree
    end

    def has_key?(key)
      self[key].present?
    end

    def save!
      puts "saving #{source_path}"
      File.open(source_path, 'w') {|f| f.write(dump( deeply_sort_hash(data) )) }
    end

    def destroy!
      puts "destroying #{source_path}"
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
      tree.to_yaml(options)
    end
  end
end
