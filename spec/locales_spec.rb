require 'spec_helper'

describe I19::Locales do
  describe "#locales" do
    it "scans for all the languages" do
      config = { locales_path: fixture_path('locales_spec'), default_locale: 'en' }
      locales = described_class.new(config)
      expect(locales.locales.length).to eq(3)
      expect(locales.locales.map(&:language)).to match_array(%w[en de es])
    end
  end
end

describe I19::Locale do
  describe "#has_key?" do
    let(:data) do
      {
        de: {
          this: {
            is: {
              "nested" => "horray"
            }
          }
        }
      }
    end
    subject { I19::Locale.new(data.keys.first, data, anything) }

    it "ignores the locale" do
      expect(subject.has_key?(:de)).to be_falsey
    end

    it "finds a first level key" do
      expect(subject.has_key?(:this)).to eq(true)
    end

    it "finds a deep level key" do
      expect(subject.has_key?("this.is.nested")).to eq(true)
    end
  end
end
