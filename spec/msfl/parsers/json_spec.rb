require 'spec_helper'

describe "MSFL::Parsers::JSON" do
  describe ".parse" do

    subject(:mut) { ::MSFL::Parsers::JSON.parse test_json }

    let(:test_json) { '{"total_funding": 5000000}' }

    context "when parsing a json hash" do

      it "returns an equivalent Ruby Hash" do
        expect(mut).to eq({ "total_funding" => 5000000 })
      end
    end

    context "when parsing a json array" do
      let(:test_json) { '["abc", "def"]' }
      it { byebug; is_expected.to be_a ::MSFL::Types::Set }
    end

  end
end