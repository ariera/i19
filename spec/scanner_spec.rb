require 'spec_helper'

describe I19::Scanners::PatternWithDefaultScanner do
  let(:test_file_path) { fixture_file('scanner_spec') }
  let(:config)         { { paths: [test_file_path] } }
  subject              { I19::Scanners::PatternWithDefaultScanner.new(config) }
  it "parses a file" do
    expect(subject.keys[2][0]).to eq("key_with_scope")
    expect(subject.keys.length).to eq(5)
  end
end
