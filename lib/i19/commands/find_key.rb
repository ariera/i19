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
        raise UnmergedLocalesError.new          unless merger.merged?
        raise UnspecifiedDefaultLocaleError.new unless config.has_key?(:default_locale_code)
        raise DefaultLocaleNotFoundError.new    unless locales.default_locale.present?
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
