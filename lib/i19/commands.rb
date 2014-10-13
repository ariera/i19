require "i19/commands/update"
require "i19/commands/merge"

module I19
  module Commands
    def self.update(options = {})
      path = options.fetch(:path, nil) || config[:path]
      default_locale = options.fetch(:default_locale, nil)
      Commands::Update.call(path, default_locale)
    end

    def self.merge(options = {})
      locales_path = options.fetch(:locales_path, nil) || config[:locales_path]
      Commands::Merge.call(locales_path)
    end

    private
    def self.config
      I19.config
    end
  end
end
