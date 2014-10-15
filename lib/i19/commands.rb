require "i19/commands/update"
require "i19/commands/merge"
require "i19/commands/find_key"

module I19
  module Commands
    def self.update(options = {})
      # path = options.fetch(:path, nil) || config[:path]
      # default_locale = options.fetch(:default_locale, nil)
      Commands::Update.call(options)
    end

    def self.merge(options = {})
      locales_path = options.fetch(:locales_path, nil) || config[:locales_path]
      Commands::Merge.call(locales_path)
    end

    def self.find_key(*args)
      Commands::FindKey.call(*args)
    end

    private
    def self.config
      I19.config
    end
  end
end
