module I19
  class Merger
    include I19::Logging
    class UnmergableError < StandardError
      attr_accessor :key, :value1, :value2
      def initialize(key, value1, value2)
        @key, @value1, @value2 = key, value1, value2
      end
    end

    attr_accessor :old_locales, :new_locales, :config
    def initialize(old_locales, options = {})
      @old_locales = old_locales.locales
      @new_locales = []
      @config = options.reverse_merge(I19.config)
    end

    def merged?
      _languages = old_locales.map(&:language)
      _languages.length == languages.length
    end

    def call
      # merge_every_langauge_into_one
      languages.each do |language|
        new_locale = Locale.new(language, {}, path_for_new_locale(language))
        new_locales << new_locale
        old_locales_by_language(language) do |locale|
          begin
            new_locale.data = deep_merge(new_locale.data, locale.data)
          rescue UnmergableError => error
            data = {
              language: language,
              conflicting_yaml_file: locale.source_path,
              key: error.key,
              value1: error.value1,
              value2: error.value2,
            }
            log_error("UnmergableError: #{data}")
            raise error
          end
        end
      end
      #delete_old_files
      old_locales.each(&:destroy!)
      #save_every_language
      new_locales.each(&:save!)
    end

    private

    def deep_merge(first, second)
      first  = first.with_indifferent_access.to_hash  # cheap way to deep_stringigy_keys
      second = second.with_indifferent_access.to_hash # cheap way to deep_stringigy_keys

      merger = proc do |key, v1, v2|
        if Hash === v1 && Hash === v2
          v1.merge(v2, &merger)
        else
          if v1 == v2
            v2
          else
            raise UnmergableError.new(key, v1, v2)
          end
        end
      end
      first.merge(second, &merger)
    end

    def path_for_new_locale(language)
      file_name = "#{config[:i19_yaml_file_name]}.#{language}.yml"
      File.join(config[:locales_path], file_name)
    end

    def languages
      @languages ||= old_locales.map(&:language).map(&:to_sym).uniq
    end

    def old_locales_by_language(language)
      old_locales.select{|loc| loc.language.to_sym == language.to_sym}.each do |locale|
        yield locale
      end
    end
  end
end
