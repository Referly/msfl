require 'spec_helper'


describe "MSFL::Sinatra" do

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

    context "when params[:dataset] is :movies" do

      let(:dataset) { :movies }

      it "is a new instance of MSFL::Datasets::Movies" do
        expect(mut).to be_a MSFL::Datasets::Movies
      end
    end

    context "when params[:dataset] is :cars" do

      let(:dataset) { :cars }

      it "is a new instance of MSFL::Datasets::Cars" do
        expect(mut).to be_a MSFL::Datasets::Cars
      end
    end
  end

  describe ".validator_from" do

    subject(:mut) { MSFL::Sinatra.validator_from params }

    let(:params) { { dataset: dataset } }

    let(:dataset) { nil }

    context "when params[:dataset] is :movies" do

      let(:dataset) { :movies }

      it "is a semantic validator instance of MSFL::Datasets::Movies" do
        validator = mut
        expect(validator).to be_a MSFL::Validators::Semantic
        expect(validator.dataset).to be_a MSFL::Datasets::Movies
      end
    end
  end

  describe ".validate" do

    subject(:mut) { MSFL::Sinatra.validate params }

    let(:params) { nil }

    it_behaves_like "an invocation of MSFL::Sinatra.validate"
  end
end