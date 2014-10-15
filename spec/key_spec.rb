require 'spec_helper'

describe I19::Key do
  describe "#valid?" do
    subject{ described_class.new(key: nil, defaults:[], source_ocurrences: []) }
    it "returns TRUE if the string DEOSN'T use ruby interpolation" do
      subject.key = "normal.every.day.key"
      expect(subject.valid?).to be_truthy
    end
    it "returns FALSE if the string uses ruby interpolation" do
      subject.key = 'interpolated.#{myvar}.key'
      expect(subject.valid?).to be_falsey
    end
  end
end
