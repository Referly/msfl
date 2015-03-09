require 'spec_helper'
require 'msfl/datasets/movies'
describe "MSFL" do

  let(:json_encoded_msfl) do
    '{
      "or": [
          {
              "and": [
                  {
                      "investors": {
                          "in": [
                              "a16z",
                              "Sequoia",
                              "nea"
                          ]
                      }
                  },
                  {
                      "last_funding_date": {
                          "gte": "2001-01-25"
                      }
                  }
              ]
          },
          {
              "total_funding": {
                  "lt": 5000000
              }
          }
      ]
    }'
  end

  let(:invalid_json_encoded_msfl) do
    '{ "not_a_field_in_dataset": "foobar" }'
  end

  let(:invalid_ruby_encoded_msfl) do
    { not_a_field_in_dataset: "foobar" }
  end

  let(:ruby_encoded_msfl) do
    {
        or: [
            {
                and: [
                    {
                        investors: {
                            in: [
                                "a16z",
                                "Sequoia",
                                "nea"
                            ]
                        }
                    },
                    {
                        last_funding_date: {
                            gte: "2001-01-25"
                        }
                    }
                ]
            },
            {
                total_funding: {
                    lt: 5000000
                }
            }
        ]
    }
  end

  let(:parser) { MSFL::Parsers::JSON }

  let(:validator) { MSFL::Validators::Semantic.new }

  it "is configured using a block" do
    MSFL.configure(reset: true) { |configuration| configuration.datasets = [MSFL::Datasets::Movies] }
    expect(MSFL.configuration.datasets).to eq [MSFL::Datasets::Movies]
  end

  it "parses json encoded MSFL" do
    expect(parser.parse json_encoded_msfl).to eq ruby_encoded_msfl
  end

  it "rejects invalid MSFL filters" do
    MSFL.configure(reset: true) { |conf| conf.datasets = [MSFL::Datasets::Movies] }
    expect(validator.validate invalid_ruby_encoded_msfl).to be false
  end

  it "accepts valid MSFL filters" do
    MSFL.configure(reset: true) { |conf| conf.datasets = [MSFL::Datasets::Movies] }
    # byebug
    expect(validator.validate ruby_encoded_msfl).to be true
  end

end