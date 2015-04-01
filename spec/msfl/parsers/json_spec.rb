require 'spec_helper'


# Still need to deal with duplicates in array scenarios - is there a nested array variation with a non-obvious deduplication consequence?
describe "MSFL::Parsers::JSON" do
  describe ".parse" do

    subject(:mut) { MSFL::Parsers::JSON.parse test_json }

    let(:test_json) { '{"total_funding": 5000000}' }

    context "when parsing an empty json string" do

      let(:test_json) { '' }

      let(:expected) { MSFL::Parsers::JSON.parse '{}' }

      it "is parsed as an empty json hash" do
        expect(mut).to eq expected
      end
    end

    context "when parsing a json hash" do

      it "is an equivalent Ruby Hash" do
        expect(mut).to eq({ :total_funding => 5000000 })
      end
    end

    context "when parsing a json array" do

      let(:test_json) { '["abc", "def"]' }

      it { is_expected.to be_a MSFL::Types::Set }
    end

  end

  describe ".convert_between_to_gte_lte" do

    subject(:mut) { MSFL::Parsers::JSON.convert_between_to_gte_lte arg }

    let(:arg) { Object.new }

    let(:deep_nest) do
      {
        cat: 1221,
        dog: "fur",
        lol: MSFL::Types::Set.new([ { hat: { between: { start: 1, end: 5 } } } ]),
        :"1337" => 1337.1337, noob: MSFL::Types::Set.new([ MSFL::Types::Set.new([123]), { :"123" => 456, onetwo: 34 } ]) }
    end

    context "when the argument is a type other than MSFL::Types::Set, Hash, or Array" do

      [55, 60.9, "five", :fourty, nil].each do |item|
        context "when the argument is a #{item.class}" do

          let(:arg) { item }

          it "is equal to the argument" do
            expect(mut).to eq arg
          end
        end
      end
    end

    context "when the argument is a Hash" do

      let(:arg) { { foo: { between: { start: "2015-01-01", end: "2015-04-01" } } } }

      let(:expected) { { foo: { gte: "2015-01-01", lte: "2015-04-01" } } }

      it "converts between clauses into anded gte / lte clauses" do
        expect(mut).to eq expected
      end

      context "when the between clause is below the second level" do

        let(:arg) do
          {
              and: MSFL::Types::Set.new([
                { foo: { between: { start: -500, end: 12 } } },
                { bar: { dog: "cat" } },
              ])
          }
        end

        let(:expected) do
          {
              and: MSFL::Types::Set.new([
                                            { foo: { gte: -500, lte: 12 } },
                                            { bar: { dog: "cat" } }
                                        ])
          }
        end

        it "recursively converts between clauses into anded gte / lte clauses" do
          expect(mut).to eq expected
        end
      end
    end

    context "when the argument is a MSFL::Types::Set" do

      let(:arg) { MSFL::Types::Set.new([ { foo: { between: { start: 1, end: 5 } } } ])}

      let(:expected) { MSFL::Types::Set.new([ { foo: { gte: 1, lte: 5 } } ]) }

      it "recursively converts between clauses into anded gte / lte clauses" do
        expect(mut).to eq expected
      end

      context "when the between clause is below the second level" do

        let(:arg) { MSFL::Types::Set.new([ { and: MSFL::Types::Set.new([{foo: { between: { start: 1, end: 5 } } }, {bar: 123}]) } ])}

        let(:expected) { MSFL::Types::Set.new([ { and: MSFL::Types::Set.new([{ foo: { gte: 1, lte: 5} }, { bar: 123} ]) }]) }

        it "recursively converts between clauses into anded gte / lte clauses" do
          expect(mut).to eq expected
        end
      end
    end

    context "when the argument contains an Array" do

      let(:arg) { [ { foo: { between: { start: 1, end: 5 } } } ] }

      it "raises an ArgumentError" do
        expect { mut }.to raise_error ArgumentError
      end
    end

    context "when the argument is deeply nested and contains many types" do

      let(:arg) { MSFL::Types::Set.new([deep_nest]) }

      let(:expected) do
        MSFL::Types::Set.new([
            {
                cat: 1221,
                dog: "fur",
                lol: MSFL::Types::Set.new(
                    [
                        { hat: { gte: 1, lte: 5} }
                    ]),
                :"1337" => 1337.1337,
                noob: MSFL::Types::Set.new(
                    [
                        MSFL::Types::Set.new([123]),
                        { :"123" => 456, onetwo: 34 }
                    ])
            }])
      end

      it "recursively converts between clauses into anded gte / lte clauses" do
        expect(mut).to eq expected
      end
    end
  end

  describe ".arrays_to_sets" do

    subject(:mut) { MSFL::Parsers::JSON.arrays_to_sets arg }

    let(:arg) { Object.new }

    [55, "five", :fourty, nil].each do |item|
      context "when the argument is a #{item.class}" do

        let(:arg) { item }

        it "is equal to the argument" do
          expect(mut).to eq arg
        end
      end
    end

    context "when the argument is a Hash" do

      context "when the hash's values are scalars" do

        let(:arg) { { foo: "bar", cat: 1337 } }

        it "is equal to the argument" do
          expect(mut).to eq arg
        end
      end

      context "when the hash's values include at least one Hash" do

        let(:arg) do
          { foo: { bar: "bar" }, abc: 123 }
        end

        it "is equal to the argument" do
          expect(mut).to eq arg
        end
      end

      context "when the hash's values include at least one Array" do

        let(:arg) do
          { inner_array: array_in_arg, abc: 123 }
        end

        let(:expected) do
          { inner_array: MSFL::Types::Set.new(array_in_arg), abc: 123 }
        end

        let(:array_in_arg) { ["bar", "baz"] }

        it "is the argument with the Array converted to a MSFL::Types::Set" do
          expect(mut).to eq expected
        end

        context "when at least one included Array has a duplicate item" do

          let(:array_in_arg) { ["cat", "cat", 44, 55, "dog", 44, :marco, :polo, nil, :polo, "cat", nil] }

          it "includes the duplicate item(s) exactly once" do
            expect(mut[:inner_array]).to eq MSFL::Types::Set.new(["cat", 44, 55, "dog", :marco, :polo, nil])
          end
        end
      end
    end

    context "when the argument is an Array" do

      let(:arg) { [:foo, "bar", nil, 99, "bar"] }

      it { is_expected.to be_a MSFL::Types::Set }

      it "is unordered" do
        expect(mut).to eq MSFL::Types::Set.new(arg.shuffle)
      end

      it "is deduplicated" do
        expect(mut).to eq MSFL::Types::Set.new([:foo, "bar", nil, 99])
      end

      context "when the array's values are scalars" do

        let(:arg) { ["bar", 1337] }

        it "is equal to MSFL::Types::Set.new(argument)" do
          expect(mut).to eq(MSFL::Types::Set.new arg)
        end
      end

      context "when the argument includes at least one Hash" do

        let(:arg) { ["bar", hash_in_arg, 84] }

        let(:hash_in_arg) { { cat: 1221, dog: "fur" } }

        it "includes the hash from the argument" do
          expect(mut).to include hash_in_arg
        end
      end

      context "when the argument includes at least one Array" do

        let(:arg) { ["bar", array_in_arg, 84] }

        let(:array_in_arg) { [444.3, "where'swaldo"] }

        let(:expected_result) { MSFL::Types::Set.new ["bar", MSFL::Types::Set.new(array_in_arg), 84] }

        it "replaces the outer Array with an equivalent MSFL::Types::Set" do
          expect(mut).to eq expected_result
        end

        it "replaces the inner Array with an equivalent MSFL::Types::Set" do
          expect(mut).to include MSFL::Types::Set.new(array_in_arg)
        end
      end
    end
  end

  describe ".convert_keys_to_symbols" do

    subject(:mut) { MSFL::Parsers::JSON.convert_keys_to_symbols arg }

    let(:arg) { Object.new }

    [55, "five", :fourty, nil].each do |item|
      context "when the argument is a #{item.class}" do

        let(:arg) { item }

        it "is equal to the argument" do
          expect(mut).to eq arg
        end
      end
    end

    context "when the argument is a Hash" do

      let(:arg) { a_hash }

      [44, "fooz", :bar].each do |key|

        let(:a_hash) { { key => "some value" } }

        let(:expected) { { "#{key}".to_sym => "some value" } }

        it "coerces the keys to symbols" do
          expect(mut).to eq expected
        end
      end

      context "when the hash's values include at least one Hash" do

        let(:a_hash) { { "cat" => { "sally" => "some value" }, 1337 => "peter", "bob" => 111 } }

        let(:expected) { { cat: { sally: "some value" }, :"1337" => "peter", bob: 111 } }

        it "recursively coerces the keys to symbols" do
          expect(mut).to eq expected
        end
      end

      context "when the hash's values include at least one Array" do

        let(:a_hash) { { "inner_array" => array_in_arg, abc: 123, 123 => :abc } }

        let(:expected) do
          { inner_array: MSFL::Types::Set.new([ MSFL::Types::Set.new([ 4, :b, { sad: "bear" } ]), "baz" ]),
            abc: 123,
            :"123" => :abc }
        end

        let(:array_in_arg) { [ [4, :b, { "sad" => "bear"} ], "baz"] }

        it "recursively coerces hash keys to symbols" do
          expect(mut).to eq expected
        end
      end

      context "when the hash's values include at least on MSFL::Types::Set" do

        let(:a_hash) { { "inner_set" => set_in_arg, abc: 123, 123 => :abc } }

        let(:expected) do
          { inner_set: MSFL::Types::Set.new([ MSFL::Types::Set.new([ 4, :b, { sad: "bear" } ]), "baz" ]),
            abc: 123,
            :"123" => :abc }
        end

        let(:set_in_arg) { MSFL::Types::Set.new([ MSFL::Types::Set.new([4, :b, { "sad" => "bear"} ]), "baz"]) }

        it "recursively coerces hash keys to symbols" do
          expect(mut).to eq expected
        end
      end
    end

    context "when the argument is an Array" do

      let(:arg) { an_array }

      let(:an_array) { [:foo, "bar", nil, 99, "bar"] }

      it "coerces Arrays into MSFL::Types::Set objects" do
        expect(mut).to be_a MSFL::Types::Set
      end

      context "when the array's values are unique scalars" do

        let(:an_array) { [:foo, "bar", nil, 99] }

        it "is unchanged" do
          expect(mut).to eq(MSFL::Types::Set.new an_array)
        end
      end

      context "when the array includes at least one Hash" do

        let(:an_array) { ["bar", hash_in_array, 84] }

        let(:hash_in_array) { { "cat" => 1221, dog: "fur", "lol" => [ ], 1337 => 1337, "noob" => [ MSFL::Types::Set.new([123]), { 123 => 456, "onetwo" => 34 } ] } }

        let(:expected) do
          MSFL::Types::Set.new(
              [
                  "bar",
                  {
                      cat: 1221,
                      dog: "fur",
                      lol: MSFL::Types::Set.new([]),
                      :"1337" => 1337,
                      noob: MSFL::Types::Set.new(
                                                [
                                                    MSFL::Types::Set.new([123]),
                                                    { :"123" => 456, onetwo: 34 }
                                                ])
                  },
                  84
              ])
        end

        it "recursively coerces hash keys to symbols" do
          expect(mut).to eq expected
        end
      end
    end
  end
end