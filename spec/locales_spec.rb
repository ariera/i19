require 'ostruct'
require 'spec_helper'
include I19

describe I19::Locales do
  describe "#locales" do
    it "scans for all the languages" do
      config = { locales_path: fixture_path('locales_spec'), default_locale_code: 'en' }
      locales = described_class.new(config)
      expect(locales.locales.length).to eq(3)
      expect(locales.locales.map(&:language)).to match_array(%w[en de es])
    end
  end

  describe "#update" do
    let(:default_locale_data) { {en: { darth: 'vader' }} }
    let(:default_locale)      { Locale.new(:en, default_locale_data, anything) }
    let(:other_locale_data)   { {de: nil} }
    let(:other_locale)        { Locale.new(:de, other_locale_data, anything) }
    let(:locales)             { Locales.new(locales:[default_locale, other_locale], default_locale_code: default_locale.language) }
    context "when the key being updated doesn't have a value" do
      context "and the default_locale has the key" do
        it "then does NOTHING" do
          key = Key.new(key: 'darth', defaults: nil, source_ocurrences: [])
          locales.update(key)
          expect(default_locale.data).to eq(default_locale_data.with_indifferent_access)
          expect(other_locale.data).to   eq({de:{}}.with_indifferent_access)
        end
      end

      context "and the default_locale DOESN'T have the key" do
        it "then marks all locales as translation pending" do
          key = Key.new(key: 'luke', defaults: nil, source_ocurrences: [])
          locales.update(key)
          expect(default_locale[:luke]).to match(Locale::PENDING_MESSAGE)
          expect(other_locale[:luke]).to   match(Locale::PENDING_MESSAGE)
        end
      end
    end

    context "when the key being updated has a value" do
      context "and the default_locale has the key" do
        context "and the key has changed" do
          it "then updates the default locale and marks the rest as pending" do
            key = Key.new(key: 'darth', defaults: 'leatherpants vader', source_ocurrences: [])
            locales.update(key)
            expect(default_locale[:darth]).to eq('leatherpants vader')
            expect(other_locale[:darth]).to   match(Locale::PENDING_MESSAGE)
            expect(other_locale[:darth]).to   match('leatherpants vader')
            expect(other_locale[:darth]).to   match('leatherpants vader')
          end
        end
        context "and the key HASN'T changed" do
          it "then does NOTHING" do
            key = Key.new(key: 'darth', defaults: 'vader', source_ocurrences: [])
            locales.update(key)
            expect(default_locale.data).to eq(default_locale_data.with_indifferent_access)
            expect(other_locale.data).to   eq({de:{}}.with_indifferent_access)
          end
        end
      end
      context "and the default_locale DOESN'T have the key" do
        it "then creates the key in the default_locale and marks the rest as pending" do
          key = Key.new(key: 'luke', defaults: 'skywalker', source_ocurrences: [])
          locales.update(key)
          expect(default_locale[:luke]).to eq('skywalker')
          expect(other_locale[:luke]).to   match(Locale::PENDING_MESSAGE)
          expect(other_locale[:luke]).to   match('skywalker')
        end
      end
    end
  end
end

describe I19::Locale do
  describe "#find_key_for_translation" do
    it "finds a key given a translation" do
      data = {
        en: {
          this: {
            is: {
              nested: "I mean, Sparta"
            }
          },
          leonidas: "Spartan"
        }
      }
      locale = Locale.new(data.keys.first, data, anything)
      expect(locale.find_key_for_translation("I mean, Sparta")).to eq({["en", "this", "is", "nested"]=>"I mean, Sparta"})
      expect(locale.find_key_for_translation(" I mean, SPARTA ")).to eq({["en", "this", "is", "nested"]=>"I mean, Sparta"})
      expect(locale.find_key_for_translation("Sparta")).to eq({["en", "this", "is", "nested"]=>"I mean, Sparta", ["en", "leonidas"]=>"Spartan"})
      expect(locale.find_key_for_translation("This doesnt yet exist")).to eq(false)
    end
  end

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

  describe "#[]=" do
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

    it "is able to update first level keys" do
      subject["this"]= "is not nested"
      expect(subject["this"]).to eq("is not nested")
    end

    it "is able to update nested keys" do
      subject["this.is.nested"]= "whatever"
      expect(subject["this.is.nested"]).to eq("whatever")
    end

    it "creates nesting if needed" do
      subject["that.didnt.exist"]= "before"
      expect(subject["that.didnt.exist"]).to eq("before")
    end
  end

  describe "#save!" do
    it "preserves utf8 encoding" do
      data = { "de" => {} }
      locale = Locale.from_file(fixture_path("locales_spec/save/de.yml"))
      expect(locale.language).to eq('de')
      expect(locale.data).to eq(data)
      key = OpenStruct.new(key: 'add_page', value:"Anzeigengruppe hinzufügen")
      locale.add_key(key)
      locale.save!(fixture_path("locales_spec/save/test_result.yml"))
    end
  end
end
