require 'spec_helper'
require 'msfl/datasets/car'
require 'msfl/datasets/person'


describe "MSFL::Sinatra" do

  describe ".registered" do

    let(:app) do
      o = Object.new
      allow(o).to receive :helpers
      expect(o).to receive(:helpers).once
      o
    end

    it "adds the methods in the Helpers module as helpers to a Sinatra application" do
      MSFL::Sinatra.registered app
    end
  end

  describe ".parse_filter_from" do

    subject(:mut) { MSFL::Sinatra.parse_filter_from params }

    let(:params) { { filter: filter } }

    let(:filter) { nil }

    context "when the params[:filter] is a hash" do

      let(:filter) { { foo: inner_array } }

      let(:inner_array) { ["cat", "dog"] }

      let(:expected) { { foo: MSFL::Types::Set.new(inner_array) } }

      it "is the MSFL parsed filter" do
        expect(mut).to eq expected
      end
    end
  end

  describe ".dataset_from" do

    subject(:mut) { MSFL::Sinatra.dataset_from params }

    let(:params) { { dataset: dataset } }

    let(:dataset) { nil }

    context "when params[:dataset] is :movie" do

      let(:dataset) { :movie }

      it "is a new instance of MSFL::Datasets::Movie" do
        expect(mut).to be_a MSFL::Datasets::Movie
      end
    end

    context "when params[:dataset] is :car" do

      let(:dataset) { :car }

      it "is a new instance of MSFL::Datasets::Car" do
        expect(mut).to be_a MSFL::Datasets::Car
      end
    end
  end

  describe ".validator_from" do

    subject(:mut) { MSFL::Sinatra.validator_from params }

    let(:params) { { dataset: dataset } }

    let(:dataset) { nil }

    context "when params[:dataset] is :movie" do

      let(:dataset) { :movie }

      it "is a semantic validator instance of MSFL::Datasets::Movie" do
        validator = mut
        expect(validator).to be_a MSFL::Validators::Semantic
        expect(validator.dataset).to be_a MSFL::Datasets::Movie
      end
    end
  end

  describe ".validate" do

    subject(:mut) { MSFL::Sinatra.validate params }

    let(:params) { nil }

    it_behaves_like "an invocation of MSFL::Sinatra.validate"

    context "when validating a foreign" do

      context "when the foreign is valid" do

        let(:params) { { dataset: :car, filter: filter } }

        let(:filter) { { foreign: { dataset: 'person', filter: { age: { gte: 25 } } } } }

        it { is_expected.to eq true }
      end
    end
  end
end