require 'terminal-table'
module I19::Commands
  class Update
    def self.call(*args)
      self.new(*args).call
    end

    attr_accessor :path
    def initialize(path, default_locale)
      @path = path
      @default_locale = default_locale || raise(ArgumentError.new("Please specify the default locale"))
      unless merger.merged?
        raise StandardError.new("There are unmerged locale files. Please merge them before (run: `i19 help merge`)")
      end
    end

    def call

      keys = scanner.keys
      puts ::Terminal::Table.new(rows: keys.map(&:to_row))
      keys.each do |key|
        if key.valid?
          locales.update(key)
        else
          puts "log_error: #{key.errors.full_messages}"
        end
      end
    end

    private
    def merger
      @merger  ||= I19::Merger.new(locales)
    end

    def scanner
      @scanner ||= I19::Scanners::PatternWithDefaultScanner.new(paths:Array(path))
    end

    def locales
      @locales ||= I19::Locales.new(default_locale: @default_locale)
    end
  end
end
