require 'spec_helper'
include I19

describe I19::Merger do
  describe "#merged?" do
    it "returns FALSE when there are unmerged locales" do
      locales_list = [:de, :de, :fr].map{ |language| Locale.new(language, {}, anything) }
      locales = Locales.new(locales: locales_list)
      merger = Merger.new(locales)
      expect(merger).to_not be_merged
    end

    it "returns TRUE when there are unmerged locales" do
      locales_list = [:de, :es, :en].map{ |language| Locale.new(language, {}, anything) }
      locales = Locales.new(locales: locales_list)
      merger = Merger.new(locales)
      expect(merger).to be_merged
    end
  end

  describe "#deep_merge" do
    let(:locales) { Locales.new(locales: []) }
    let(:merger)  { Merger.new(locales) }
    it "merges stuff" do
      first  = { a: 1, c: 4 }
      second = { b: 3 }
      result = merger.send(:deep_merge, first, second)
      expect(result).to eq({ "a"=>1, "b"=>3, "c"=>4 })
    end

    it "merges deep stuff" do
      first  = { a: { c: 4 } }
      second = { a: { b: 3 } }
      result = merger.send(:deep_merge, first, second)
      expect(result).to eq({ "a"=>{ "b"=>3, "c"=>4 } })
    end

    it "merges without caring if keys are strings or symbols" do
      first  = { :a  => { c: 4 } }
      second = { "a" => { b: 3 } }
      result = merger.send(:deep_merge, first, second)
      expect(result).to eq({ "a"=>{ "b"=>3, "c"=>4 } })
    end

    it "merges colling stuff with same values" do
      first  = { a: 1 }
      second = { a: 1 }
      result = merger.send(:deep_merge, first, second)
      expect(result).to eq({ "a"=>1 })
    end

    it "raises if collides with different values" do
      first  = { a: 1 }
      second = { a: 2 }
      expect{ merger.send(:deep_merge, first, second) }.to raise_error(described_class::UnmergableError)
    end
  end

  describe "#call" do
    it "successfully merges 2 same-language files" do
      config = { locales_path: fixture_path('merger_spec/call_success'), i19_yaml_file_name: 'test_result'}
      older_test_files_to_delete = Dir.glob(File.join(config[:locales_path], "#{config[:i19_yaml_file_name]}*.yml"))
      FileUtils.rm_f(older_test_files_to_delete)
      allow_any_instance_of(Locale).to receive(:destroy!)

      locales = Locales.new(config)
      merger = Merger.new(locales, config)
      merger.call
      result = YAML.load(File.open(File.join(config[:locales_path], "#{config[:i19_yaml_file_name]}.en.yml")))

      merged_data = {
        "en" => {
          "star_wars" => {
            "rebellion" => {
              "luke"=>"Luke Skywalker"
            },
            "empire" => {
              "darth_vader"=>"Darth Vader"
            }
          },
          "futurama" => {
            "bender"=>"Bender Bending Rodríguez"
          },
          "babylon5" => {
            "gkar"=>"G'Kar"
          }
        }
      }
      expect(result).to eq(merged_data)
    end

    it "raises and error when conflicts found in 2 same-language files"
  end
end
