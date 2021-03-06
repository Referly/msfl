require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    class Person < ::MSFL::Datasets::Base
      register_dataset

      def foreigns
        [:car, :animal]
      end

      def fields
        [:name, :gender, :age]
      end
    end
  end
end
