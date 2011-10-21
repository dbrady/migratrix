require 'spec_helper'

class TestYamlLoad < Migratrix::Loads::Yaml
end

describe Migratrix::Loads::Yaml do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Loads::Load.should_not be_nil
      TestYamlLoad.should_not be_nil
    end
  end

  let(:loggable) { TestYamlLoad.new(:loggable) }
  it_should_behave_like "loggable"

  describe ".local_valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Loads::Yaml.local_valid_options.should == [:filename]
    end
  end

  describe "#load" do
    let(:input) { [1, 2, 3]}
    let(:output) { "---\n- 1\n- 2\n- 3\n"}
    let(:buffer) { StringIO.new }
    let(:load) { TestYamlLoad.new(:test, filename: '/tmp/test.yml')}

    before do
      File.should_receive(:open).with('/tmp/test.yml', 'w').and_yield(buffer)
    end

    it "writes transformed_items to file as YAML" do
      load.load(input)
      buffer.string.should == output
    end
  end
end

