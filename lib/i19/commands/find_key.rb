module I19
  module Commands
    class FindKey
      include I19::Logging
      def self.call(*args)
        self.new(*args).call
      end

      attr_accessor :query, :config
      def initialize(options)
        @query = options.delete(:query)
        @config = options.reverse_merge(default_options)
        unless merger.merged?
          raise StandardError.new("There are unmerged locale files. Please merge them before (run: `i19 help merge`)")
        end
        unless config.has_key?(:default_locale_code)
          raise ArgumentError.new("Please specify the default locale")
        end
        unless locales.default_locale.present?
          raise StandardError.new("default locale not found")
        end
      end

      def call
        result = locales.default_locale.find_key_for_translation(query)
        if result
          log_success("Results for '#{query}'")
          result = result.map{ |keys, translation| [keys.join("."), translation] }
          puts ::Terminal::Table.new(rows: result)
        else
          log_error("Nothing found for '#{query}'")
        end
      end

      private
      def default_options
        I19.config.slice(:locales_path)
      end

      def merger
        @merger  ||= I19::Merger.new(locales)
      end

      def locales
        @locales ||= I19::Locales.new(locales_path: config[:locales_path], default_locale_code: config[:default_locale_code])
      end
    end
  end
end
