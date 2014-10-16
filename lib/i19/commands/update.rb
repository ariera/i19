require 'terminal-table'
module I19::Commands
  class Update
    include I19::Logging

    def self.call(*args)
      self.new(*args).call
    end

    attr_accessor :search_path, :save, :config
    def initialize(options)
      @config = options.reverse_merge(I19.config)

      unless merger.merged?
        raise StandardError.new("There are unmerged locale files. Please merge them before (run: `i19 help merge`)")
      end
      unless config.has_key?(:default_locale_code)
        raise ArgumentError.new("Please specify the default locale")
      end
      unless locales.default_locale.present?
        raise StandardError.new("default locale not found")
      end
      unless locales.locales.present?
        raise StandardError.new("locales not found")
      end
    end

    def call
      keys = scanner.keys
      puts ::Terminal::Table.new(title:"All the keys found", rows: keys.map(&:to_row))
      keys.each do |key|
        if key.valid?
          event_log << locales.update(key)
        else
          event_log << Event.new(level: Event::LEVEL[:error], type: :invalid_key, data: key, message: key.errors.full_messages)
        end
      end

      if config[:save]
        locales.save!
      end
      print_event_log
    end

    private

    def merger
      @merger  ||= I19::Merger.new(locales)
    end

    def scanner
      @scanner ||= I19::Scanners::PatternWithDefaultScanner.new(paths:Array(config[:search_path]))
    end

    def locales
      @locales ||= I19::Locales.new(locales_path: config[:locales_path], default_locale_code: config[:default_locale_code])
    end
  end
end
