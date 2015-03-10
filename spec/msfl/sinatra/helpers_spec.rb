require 'spec_helper'

describe "MSFL::Sinatra::Helpers" do

  let(:sinatra_app_class) do
    klass = class SinatraTestAppClass
              # In a proper Sinatra app there would be no need to this because when the extension is registered the helpers
              #  are automatically mixed in
      include MSFL::Sinatra::Helpers
    end
    klass
  end

  let(:sinatra_app) { sinatra_app_class.new }

  let(:params) { nil }

  describe "#msfl_valid?" do

    subject(:mut) { sinatra_app.msfl_valid? params }

    # it_behaves_like "an invocation of MSFL::Sinatra.validate"
  end

  describe "#msfl_filter" do

    subject(:mut) { sinatra_app.msfl_filter params }

    context "when Sinatra.valid_filter is a valid MSFL filter" do

      let(:valid_filter) { { arbitrary: "hash" } }

      before { MSFL::Sinatra.valid_filter = valid_filter }

      it "is the valid MSFL filter" do
        expect(mut).to eq valid_filter
      end

    end

    context "when Sinatra.valid_filter is nil" do

      before(:each) { MSFL::Sinatra.valid_filter = nil }

      let(:params) { { filter: filter, dataset: dataset } }

      let(:filter) { nil }

      let(:dataset) { nil }

      context "when params[:dataset] is nil" do

        context "when params[:filter] is valid json" do

          let(:filter) { { notavalidmsflkeybutokjson: ["a", "b"] } }

          it "raises a NoMethodError" do
            expect { mut }.to raise_error NoMethodError
          end
        end
      end

      context "when params[:dataset] does not correspond to a registerd MSFL::Dataset" do

      end

      context "when params[:filter] is not valid json" do

        let(:filter) { "iamnotvalidjson" }

        it "raises a JSON::ParserError" do
          expect { mut }.to raise_error JSON::ParserError
        end
      end

      context "when params[:filter] is nil" do

        it "raises an ArgumentError" do
          expect { mut }.to raise_error ArgumentError
        end
      end

      context "when params[:dataset] is a valid Dataset" do

        let(:dataset) { :movies }

        context "when params[:filter] is a valid MSFL filter" do

          let(:filter) { { title: { in: inner_array } } }

          let(:inner_array) { ["Shrek", "Harry Potter"] }

          let(:msfl_filter) { { title: { in: MSFL::Types::Set.new(inner_array) } } }

          it "is the valid MSFL filter" do
            expect(mut).to eq msfl_filter
          end
        end
      end
    end
  end
end