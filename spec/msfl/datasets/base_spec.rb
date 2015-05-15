require 'spec_helper'

describe "MSFL::Datasets::Base" do

  let(:test_instance) { MSFL::Datasets::Movie.new }

  let(:errors) { [ ] }

  let(:field) { :title }

  describe "#fields" do

    it "raises a NoMethodError" do
      expect { MSFL::Datasets::Base.new.fields }.to raise_error NoMethodError
    end
  end

  describe "#validate_type_conforms" do

    subject(:mut) { test_instance.validate_type_conforms obj, field, errors }

    let(:obj) { "i am a string" }

    it "is currently a stubbed method that just returns the errors argument" do
      expect(mut).to eq errors
    end
  end

  describe "#type_conforms?" do

    context "when MSFL is configured to use Movie as the dataset" do

      subject(:mut) { test_instance.type_conforms? obj, field }

      let(:obj) { "i am a string" }

      it "is true for types that conform to the Dataset" do
        expect(mut).to eq true
      end

      it "is false for types that do not conform to the Dataset" do
        pending "Dataset specific semantic validation is not yet implemented."
        expect(mut).to eq false
      end
    end
  end

  describe "#validate_operator_conforms" do

    subject(:mut) { test_instance.validate_operator_conforms operator, field, errors }

    let(:operator) { :and }

    it "is currently a stubbed method that just returns the errors argument" do
      expect(mut).to eq errors
    end
  end

  describe "#validate_value_conforms" do

    subject(:mut) { test_instance.validate_value_conforms value, field, errors }

    let(:value) { 1234 }

    it "is currently a stubbed method that just returns the errors argument" do
      expect(mut).to eq errors
    end
  end

  describe "#foreigns" do

    subject { test_instance.foreigns }

    it "is intended to be overridden" do
      expect(subject).to eq []
    end
  end
end