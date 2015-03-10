require 'spec_helper'

describe "MSFL::Validators::Semantic" do

  describe "#initialize" do

    subject(:mut) { MSFL::Validators::Semantic.new dataset }

    let(:dataset) { nil }

    context "when the dataset argument is specified" do

      let(:dataset) { Object.new }

      it "has the dataset argument's value as the dataset" do
        expect(mut.dataset).to be dataset
      end
    end

    context "when the dataset argument is not specified" do

      context "when MSFL is configured for one or more datasets" do

        before { MSFL.configure(reset: true) { |configuration| configuration.datasets = [MSFL::Datasets::Movies] } }

        it "has an instance of the first item in MSFL.configuration.datasets (an instance of Class) as the dataset" do
          expect(mut.dataset).to be_a MSFL::Datasets::Movies
        end
      end

      context "when MSFL is not configured for any datasets" do

        before { MSFL.configure(reset: true) }

        it "has an instance of MSFL::Datasets::Base as the dataset" do
          expect(mut.dataset).to be_a MSFL::Datasets::Base
        end
      end
    end

  end

  describe "#validate" do

    subject(:mut) { test_instance.validate hash, errors, options }

    let(:test_instance) { MSFL::Validators::Semantic.new }

    let(:hash) { {} }

    let(:errors) { [] }

    let(:options) { {} }

    context "when the filter is empty" do
      it { is_expected.to be true }
    end
  end

  describe "#validate_set" do

    subject(:mut) { test_instance.validate_set set, errors, options }

    let(:test_instance) { MSFL::Validators::Semantic.new }

    let(:set) { MSFL::Types::Set.new([ ]) }

    let(:errors) { [ ] }

    let(:options) { { } }

    context "when the errors argument has items" do

      let(:errors) { [error_message] }

      let(:error_message) { "This is an error message" }

      it "is an array containing at least all of the error messages from the original errors argument" do
        expect(mut).to include error_message
      end
    end

    context "when opts does not have the key :parent_operator" do

      let(:error_message) do
        "Validate set requires the :parent_operator option be set and represented in either the BOOLEAN_OPERATORS
            or ENUMERATION_OPERATORS constant"
      end

      it "appends an error to errors" do
        expect(mut).to include error_message
      end
    end

    context "when opts[:parent_operator] is in BOOLEAN_OPERATORS" do

      let(:options) { { parent_operator: :and } }

      let(:test_instance) do
        t_i = MSFL::Validators::Semantic.new
        allow(t_i).to receive(:validate_boolean_set) { errors }
        expect(t_i).to receive(:validate_boolean_set).once.with(set, errors, options)
        t_i
      end

      it "invokes #validate_boolean_set once with the same arguments" do
        mut
      end
    end

    context "when opts[:parent_operator] is in ENUMERATION_OPERATORS" do

      let(:options) { { parent_operator: :in } }

      let(:test_instance) do
        t_i = MSFL::Validators::Semantic.new
        allow(t_i).to receive(:validate_enumeration_set) { errors }
        expect(t_i).to receive(:validate_enumeration_set).once.with(set, errors, options)
        t_i
      end

      it "invokes #validate_enumeration_set once with the same arguments" do
        mut
      end
    end

    context "when opts[:parent_operator] is not in neither BOOLEAN_OPERATORS nor ENUMERATION_OPERATORS" do

      let(:options) { { parent_operator: :not_in_either } }

      let(:error_message) do
        "Validate set requires the :parent_operator option be set and represented in either the BOOLEAN_OPERATORS
            or ENUMERATION_OPERATORS constant"
      end

      it "appends an error to errors" do
        expect(mut).to include error_message
      end
    end
  end
end