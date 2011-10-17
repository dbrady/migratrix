require 'spec_helper'

describe String do
  describe "#plural?" do
    it "identifies plural strings" do
      "shirts".should be_plural
    end

    it "identifies collectively plural strings" do
      "people".should be_plural
    end

    it "ignores singular strings" do
      "sock".should_not be_plural
    end
  end

  describe "#singular?" do
    it "identifies singular strings" do
      "shirt".should be_singular
    end

    it "identifies collectively plural strings as singular" do
      "person".should be_singular
    end

    it "ignores plural strings" do
      "socks".should_not be_singular
    end
  end


end
