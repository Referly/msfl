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

  describe "#has_operator?" do

    let(:test_instance) { MSFL::Datasets::Person.new }

    let(:operator) { :eq }

    subject { test_instance.has_operator? operator }

    context "when the dataset has the specified operator" do

      it { is_expected.to eq true }
    end

    context "when the dataset does not have the specified operator" do

      context "when the dataset has a foreign dataset that has the specified operator" do

        let(:operator) { :animal_specific_operator }

        it { is_expected.to eq true }
      end

      context "when the dataset does not have a foreign dataset that has the specified operator" do

        let(:operator) { :not_an_operator }

        it { is_expected.to eq false }
      end
    end
  end

  describe "#has_field?" do

    let(:test_instance) { MSFL::Datasets::Car.new }

    let(:field_name) { :make }

    subject { test_instance.has_field? field_name }

    context "when the dataset has the specified field" do

      it { is_expected.to eq true }
    end

    context "when the dataset has a foreign data set that has the specified field" do

      let(:field_name) { :gender }

      it { is_expected.to eq true }
    end

    context "when the dataset does not have the specified field" do

      context "when none of the dataset's foreign datasets have the specified field" do

        let(:field_name) { :not_a_field }

        it { is_expected.to eq false }
      end
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