require 'spec_helper'

describe MSFL::Validators::Definitions::HashKey do

  module TestClassNamespace
    class IncludesHashKey
      include MSFL::Validators::Definitions::HashKey
      attr_accessor :dataset
    end
  end

  context "when a class includes #{described_class}" do

    let(:test_instance) { TestClassNamespace::IncludesHashKey.new }

    describe "#valid_hash_keys" do

      before { test_instance.dataset = dataset }

      let(:dataset) do
        d = double('Dataset')
        allow(d).to receive(:fields).and_return [:foo, :bar]
        d
      end

      subject { test_instance.valid_hash_keys }

      it "includes all of the valid operators" do
        expect(subject).to include *(test_instance.hash_key_operators)
      end

      it "includes all of the valid fields" do
        expect(subject).to include *(test_instance.dataset.fields)

      end
    end
  end
end