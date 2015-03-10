shared_examples_for "an invocation of MSFL::Sinatra.validate" do

  let(:params) { { dataset: dataset, filter: filter } }

  context "when params[:filter] is nil" do

    let(:filter) { nil }

    let(:dataset) { nil }

    it { is_expected.to be true }
  end

  context "when params[:filter] is an empty hash" do

    let(:filter) { {} }

    let(:dataset) { nil }

    it { is_expected.to be true }
  end

  context "when params[:dataset] is :movies" do

    let(:dataset) { :movies }

    context "when params[:filter] is a valid filter" do

      let(:filter) { { title: "Gone with the wind" } }

      it { is_expected.to be true }
    end

    context "when params[:filter] is an invalid filter" do

      let(:filter) { { notavalidfield: "some arbitrary value" } }

      it { is_expected.to be false }
    end
  end
end