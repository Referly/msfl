require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    class Car < ::MSFL::Datasets::Base
      register_dataset

      def foreigns
        [:person]
      end

      def fields
        [:make, :model, :year, :value]
      end
    end
  end
end
