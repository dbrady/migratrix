require 'spec_helper'

class TestMap < Migratrix::Transforms::Map
end

describe Migratrix::Transforms::Map do
  describe "sanity check cat" do
    it "is sanity checked" do
      Migratrix::Transforms::Map.should_not be_nil
      TestMap.should_not be_nil
    end
  end

  describe ".local_valid_options" do
    it "returns the valid set of option keys" do
      Migratrix::Transforms::Map.local_valid_options.should == []
    end
  end

  describe ".valid_options" do
    it "returns the valide set of options plus those of the superclass" do
      Migratrix::Transforms::Map.valid_options.should == Migratrix::Transforms::Transform.local_valid_options
    end
  end

  describe "with pet types fixture" do
    let(:extracted_pets) {
      [
        { :pet_type_id => 42, :pet_species => 'Dog' },
        { :pet_type_id => 43, :pet_species => 'Cat' },
        { :pet_type_id => 44, :pet_species => 'Rat' },
        { :pet_type_id => 45, :pet_species => 'Parrot' }
      ]
    }
    let(:map) {  { :id => :pet_type_id, :name => :pet_species } }
    let(:expected_transform) { {
        42 => { :id => 42, :name => 'Dog' },
        43 => { :id => 43, :name => 'Cat' },
        44 => { :id => 44, :name => 'Rat' },
        45 => { :id => 45, :name => 'Parrot' }
      }
    }
    let(:transform) { Migratrix::Transforms::Map.new(:pet_types, :transform => map) }

    it "transforms data correctly" do
      with_logging_to(StringIO.new) do
        transform.transform(extracted_pets).should == expected_transform
      end
    end
  end
end

