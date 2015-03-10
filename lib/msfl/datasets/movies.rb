require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    class Movies < ::MSFL::Datasets::Base
      register_dataset

      def fields
        [:title, :rating, :description, :earnings]
      end
    end
  end
end
