require 'spec_helper'

describe Migratrix::Registry do
  describe "sanity check cat" do
    it "is sanity checked" do
      ::Migratrix::Registry.should_not be_nil
    end
  end

  describe "#register" do
    let(:registry) { ::Migratrix::Registry.new }
    before do
      registry.register(:test, Array, 3)
    end

    it "registers the class by name" do
      registry.registered?(:test).should be_true
    end

    describe "#class_for" do
      it "returns the registered class" do
        registry.class_for(:test).should == Array
      end
    end

    describe "#options_for" do
      it "returns the registered options" do
        registry.options_for(:test).should == 3
      end
    end
  end
end


