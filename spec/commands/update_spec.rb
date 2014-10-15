require 'spec_helper'

describe I19::Commands::Update do
  describe "#call" do
    it "works" do
      config = {
        search_path: fixture_path("command_update"),
        locales_path: fixture_path("command_update"),
        default_locale_code: :de,
        save: false,
      }
      update_command = described_class.new(config)
      update_command.call
    end
  end
end
