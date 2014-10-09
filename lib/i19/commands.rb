require "i19/commands/update"

module I19
  module Commands
    DEFAULT_OPTIONS = {
      path: './app'
    }.freeze

    def self.update(options = {})
      path = options.fetch(:path, nil) || config(:path)
      Commands::Update.call(path)
    end

    private
    def self.config(opt)
      DEFAULT_OPTIONS[opt]
    end
  end
end
