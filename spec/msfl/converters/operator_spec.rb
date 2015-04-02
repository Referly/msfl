require 'spec_helper'

describe "MSFL::Converters::Operator" do

  describe "#run_conversions" do

    subject { test_instance.run_conversions obj, conversions_to_run }

    let(:klass) do
      class OpTestConverter < MSFL::Converters::Operator
      end
      OpTestConverter
    end

    let(:test_instance) { klass.new }

    let(:obj) { Object.new }

    let(:conversions_to_run) { nil }

    context "when the conversions_to_run argument is nil" do

      let(:test_instance) do
        t_i = klass.new

        allow(t_i).to receive(:implicit_between_to_explicit_recursively)
        expect(t_i).to receive(:implicit_between_to_explicit_recursively).once

        allow(t_i).to receive(:between_to_gte_lte_recursively)
        expect(t_i).to receive(:between_to_gte_lte_recursively).once

        allow(t_i).to receive(:implicit_and_to_explicit_recursively)
        expect(t_i).to receive(:implicit_and_to_explicit_recursively).once
        t_i
      end

      it "runs all conversions in CONVERSIONS" do
        subject
      end
    end

    context "when conversions_to_run is an array of symbols" do

      let(:conversions_to_run) { [:implicit_and_to_explicit_recursively, :between_to_gte_lte_recursively]}

      it "runs all elements in CONVERSIONS that are in conversions_to_run" do
        allow(test_instance).to receive :implicit_and_to_explicit_recursively
        expect(test_instance).to receive(:implicit_and_to_explicit_recursively)

        allow(test_instance).to receive :between_to_gte_lte_recursively
        expect(test_instance).to receive(:between_to_gte_lte_recursively)

        allow(test_instance).to receive :implicit_between_to_explicit_recursively
        expect(test_instance).to receive(:implicit_between_to_explicit_recursively).never

        subject
      end

      it "runs the indicated conversions exactly once" do

        allow(test_instance).to receive :implicit_and_to_explicit_recursively
        expect(test_instance).to receive(:implicit_and_to_explicit_recursively).once

        allow(test_instance).to receive :between_to_gte_lte_recursively
        expect(test_instance).to receive(:between_to_gte_lte_recursively).once

        subject
      end

      it "runs the indicated conversions in the order they appear in CONVERSIONS" do

        allow(test_instance).to receive :between_to_gte_lte_recursively
        expect(test_instance).to receive(:between_to_gte_lte_recursively).ordered

        allow(test_instance).to receive :implicit_and_to_explicit_recursively
        expect(test_instance).to receive(:implicit_and_to_explicit_recursively).ordered

        subject
      end
    end


    context "when conversions_to_run is not nil and not an array of symbols" do

      let(:conversions_to_run) { "foo" }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "#implicit_between_to_explicit_recursively" do

    subject { test_instance.implicit_between_to_explicit_recursively arg }

    let(:test_instance) { MSFL::Converters::Operator.new }

    let(:arg) { raise ArgumentError, "You are expected to define the arg variable" }

    let(:expected) { raise ArgumentError, "You are expected to define the expected value" }

    context "when there is not an implicit BETWEEN" do

      ["foo", { foo: "bar" }, 123, 56.12, :aaaah].each do |arg|

        context "when the argument is #{arg}" do

          let(:arg) { arg }

          it "is the argument unchanged" do
            expect(subject).to eq arg
          end
        end
      end
    end

    context "when there is an implicit BETWEEN" do

      context "when the implicit BETWEEN is at the highest possible level of the filter" do

        let(:arg) { { year: { start: 2001, end: 2005 } } }

        let(:expected) { { year: { between: { start: 2001, end: 2005 } } } }

        it "is an explicit BETWEEN" do
          expect(subject).to eq expected
        end
      end

      context "when the implicit BETWEEN is inside of a MSFL::Types::Set" do

        let(:arg) do
          { and:
                MSFL::Types::Set.new([
                                         { make: "Honda"},
                                         { year: { start: 2001, end: 2005 } }
                                 ])
          }
        end

        let(:expected) do
          { and: MSFL::Types::Set.new([
                                          { make: "Honda" },
                                          { year: { between: { start: 2001, end: 2005 } } }
                                      ])}
        end

        it "recursively converts the implicit BETWEEN to an explicit BETWEEN" do
          expect(subject).to eq expected
        end
      end

      # This can't actually happen in the current MSFL syntax (at least I don't think it can)
      context "when the implicit BETWEEN is inside of another Hash" do

        let(:arg) do
          { foo: { bar: { start: "2015-01-01", end: "2015-03-01" } } }
        end

        let(:expected) do
          { foo: { bar: { between: { start: "2015-01-01", end: "2015-03-01" } } } }
        end

        it "recursively converts the implicit BETWEEN to an explicit BETWEEN" do
          expect(subject).to eq expected
        end
      end

      context "when there are multiple implicit BETWEENs that are deeply nested" do

        let(:deep_nest) do
          {
              cat: 1221,
              dog: "fur",
              lol: MSFL::Types::Set.new([ { hat: { start: 1, end: 5 } } ]),
              :"1337" => 1337.1337,
              noob: MSFL::Types::Set.new([
                                             MSFL::Types::Set.new([123]),
                                             { :"123" => 456, onetwo: { start: 3, end: 4 } } ]) }
        end

        let(:arg) { deep_nest }

        let(:expected) do
          {
              cat: 1221,
              dog: "fur",
              lol: MSFL::Types::Set.new([
                                            { hat: { between: { start: 1, end: 5 } } }
                                        ]),
              :"1337" => 1337.1337,
              noob: MSFL::Types::Set.new([
                                             MSFL::Types::Set.new([123]),
                                             { :"123" => 456, onetwo: { between: { start: 3, end: 4 } } }
                                         ])
          }
        end

        it "recursively converts the implicit BETWEENs to an explicit BETWEENs" do
          expect(subject).to eq expected
        end
      end
    end
  end

  describe "#implicit_and_to_explicit" do

    subject(:mut) { test_instance.implicit_and_to_explicit_recursively arg }

    let(:test_instance) { MSFL::Converters::Operator.new }

    let(:arg) { raise ArgumentError, "You are expected to define the arg variable" }

    let(:expected) { raise ArgumentError, "You are expected to define the expected value" }

    context "when there is not an implicit AND" do

      let(:expected) { arg }

      context "when the arg is a scalar" do

        let(:arg) { 50 }

        it "is the arg unchanged" do
          expect(mut).to eq expected
        end
      end

      context "when the arg is single level" do

        let(:arg) { { gte: 1000 }  }

        it "is the arg unchanged" do
          expect(mut).to eq expected
        end
      end

      context "when the arg is multi level" do

        let(:arg) { { value: { gte: 1000 } } }

        it "is the arg unchanged" do
          expect(mut).to eq expected
        end
      end


    end

    context "when the implicit AND exists on a Hash whose keys are fields" do

      # TYPE 1 --- { make: "chevy", year: 2010 } => { and: [ { make: "chevy" }, { year: 2010 }] }
      let(:arg) { { make: "chevy", year: 2010 } }

      let(:expected) { { and: MSFL::Types::Set.new([
                                                       { make: "chevy" },
                                                       { year: 2010 }
                                                   ])}}

      it "converts the implicit AND to an explicit AND" do
        expect(mut).to eq expected
      end
    end

    context "when the implicit AND exists on a Hash whose value is a Hash with multiple operator keys" do

      # TYPE 2 --- { year: { gte: 2010, lte: 2012 } } => { and: [ { year: { gte: 2010 } }, { year: { lte: 2012 } } ] }
      let(:arg) { { year: { gte: 2010, lte: 2012 } } }

      let(:expected) { { and: MSFL::Types::Set.new([
                                                       { year: { gte: 2010 } },
                                                       { year: { lte: 2012 } }
                                                   ])}}

      it "converts the implicit AND to an explicit AND" do
        expect(mut).to eq expected
      end
    end

    context "when the implicit AND exists on a Hash whose keys are fields" do

      context "when the implicit AND exists on a Hash whose value is a Hash with multiple operator keys" do

        # TYPE 3 --- { make: "chevy", year: { gte: 2010, lte: 2012 } } => { and: [ { make: "chevy" }, { and: [ { year: { gte: 2010 } }, { year: { lte: 2012 } } ] } ] }
        let(:arg) { { make: "chevy", year: { gte: 2010, lte: 2012 } } }

        let(:expected) do
          { and: MSFL::Types::Set.new([
                                          { make: "chevy" },
                                          { and: MSFL::Types::Set.new([
                                                                          { year: { gte: 2010 } },
                                                                          { year: { lte: 2012 } }
                                                                      ])}
                                      ])}
        end

        it "converts both of the implicit ANDs to explicit ANDs" do
          expect(mut).to eq expected
        end
      end
    end

    context "when the implicit AND is within a MSFL::Types::Set" do

      let(:arg) do
        { and: MSFL::Types::Set.new([
                                       { make: "chevy", year: { gte: 2010, lte: 2012 } },
                                       { value: { gte: 1000 } }
                                   ])}
      end

      let(:expected) do
        { and: MSFL::Types::Set.new([
                                       { and: MSFL::Types::Set.new([
                                                                       { make: "chevy" },
                                                                       { and: MSFL::Types::Set.new([
                                                                                                       { year: { gte: 2010 } },
                                                                                                       { year: { lte: 2012 } }
                                                                                                   ])}
                                       ])},
                                       { value: { gte: 1000 } }
                                   ])}
      end

      it "converts all of the implicit ANDs" do
        expect(mut).to eq expected
      end
    end
  end

  describe "#between_to_gte_lte_recursively" do

    subject(:mut) { test_instance.between_to_gte_lte_recursively arg }

    let(:test_instance) { MSFL::Converters::Operator.new }

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
end