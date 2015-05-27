require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    # It differs from the other examples in that it overrides #operators
    class Animal < ::MSFL::Datasets::Base
      register_dataset

      def foreigns
        [:person]
      end

      def fields
        [:name, :gender, :age, :type]
      end

      def operators
        super.concat [:animal_specific_operator]
      end
    end
  end
end
