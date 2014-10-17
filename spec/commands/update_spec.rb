require 'spec_helper'

describe I19::Commands::Update do
  describe "#call" do
    def cleanup_working_dir
      Dir.glob(File.join(fixture_path("command_update"), "*")) do |file_path|
        if File.file?(file_path)
          puts "removing: #{file_path}"
          FileUtils.rm_f(file_path)
        end
      end
    end

    def copy_templates_to_working_dir
      destination_path = fixture_path("command_update")
      Dir.glob(File.join(fixture_path("command_update/templates"), "*")) do |file_path|
        puts "copying: #{file_path} to #{destination_path}"
        FileUtils.cp(file_path, destination_path)
      end
    end

    def expected_default_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update/expected"), "expected.i19.en.yml")
    end

    def expected_other_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update/expected"), "expected.i19.es.yml")
    end

    def expected_missing_default_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update/expected"), "expected.i19.missing.en.yml")
    end

    def expected_missing_other_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update/expected"), "expected.i19.missing.es.yml")
    end

    def result_default_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update"), "i19.en.yml")
    end

    def result_other_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update"), "i19.es.yml")
    end

    def result_missing_default_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update"), "i19.missing.en.yml")
    end

    def result_missing_other_locale_data
      load_and_flat_yaml_file File.join(fixture_path("command_update"), "i19.missing.es.yml")
    end

    def load_and_flat_yaml_file(file_path)
       flat_hash YAML.load(File.open(file_path))
    end

    # http://stackoverflow.com/a/23861946/159537
    def flat_hash(h,f=[],g={})
      return g.update({ f=>h }) unless h.is_a? Hash
      h.each { |k,r| flat_hash(r,f+[k],g) }
      g
    end

    it "works" do
      cleanup_working_dir
      copy_templates_to_working_dir


      config = {
        search_path: fixture_path("command_update"),
        locales_path: fixture_path("command_update"),
        default_locale_code: :en,
        save: true,
      }
      update_command = described_class.new(config)
      update_command.call

      expect(result_default_locale_data).to         eq(expected_default_locale_data)
      expect(result_other_locale_data).to           eq(expected_other_locale_data)
      expect(result_missing_default_locale_data).to eq(expected_missing_default_locale_data)
      expect(result_missing_other_locale_data).to   eq(expected_missing_other_locale_data)
    end
  end
end
