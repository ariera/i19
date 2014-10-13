require 'spec_helper'

describe I19::Scanners::PatternWithDefaultScanner do
  let(:test_file_path) { fixture_path('scanner_spec') }
  let(:config)         { { paths: [test_file_path] } }
  subject              { I19::Scanners::PatternWithDefaultScanner.new(config) }
  it "parses a file" do
    keys = %W[ total_cost my_scope.key_with_scope key_with_default key_with_default_and_params are_you_sure_destroy_page]
    translation_calls = subject.keys
    expect(translation_calls.length).to eq(5)
    expect(translation_calls.map(&:key)).to match_array(keys)
    expect(translation_calls.find{|t| t.key == "key_with_default"}.default).to eq('Kosten dieser Monat')
    expect(translation_calls.find{|t| t.key == "key_with_default_and_params"}.default).to eq('Kosten dieser %{count} Monat')
  end

  describe 'default pattern' do
    let!(:pattern) { I19::Scanners::PatternWithDefaultScanner.new.default_pattern }

    ['t "a.b"', "t 'a.b'", 't("a.b")', "t('a.b')",
     "t('a.b', :arg => val)", "t('a.b', arg: val)",
     "t :a_b", "t :'a.b'", 't :"a.b"', "t(:ab)", "t(:'a.b')", 't(:"a.b")',
    'I18n.t("a.b")', 'I18n.translate("a.b")'].each do |s|
      it "matches #{s}" do
        expect(pattern).to match s
      end
    end


    ['t "a.b", scope: "this is my scope"',
     't "a.b", default:"this is my default"',
     't "a.b", scope: "this is my scope", default:"this is my default"',
     't "a.b", scope: "this is my scope", default:"this is my default", even_more_arguments: "args"',
      ].each do |s|
      it "matches #{s}" do
        expect(pattern).to match(s)
      end
    end

    # ["t \"a.b'", "t a.b"].each do |s|
    #   it "does not match #{s}" do
    #     expect(pattern).to_not match s
    #   end
    # end
  end

end
