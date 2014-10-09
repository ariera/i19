require "i19/commands/updater"

module I19
  module Commands
    DEFAULT_OPTIONS = {
      path: './app'
    }.freeze

    def self.update(options = {})
      path = options[:path] || config(:path)
      Commands::Updater.call(path)
    end

    private
    def self.config(opt)
      DEFAULT_OPTIONS[opt]
    end
  end
end
