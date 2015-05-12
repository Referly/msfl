require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    class Person < ::MSFL::Datasets::Base
      register_dataset

      def fields
        [:name, :gender, :age, :cars]
      end
    end
  end
end
