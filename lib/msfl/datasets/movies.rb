require_relative 'base'

module MSFL
  module Datasets
    # This is a fake dataset definition that shows the structure for composing your own and is used for testing
    #  msfl
    class Movies < ::MSFL::Datasets::Base
      def fields
        [:title, :rating, :description]
      end
    end
  end
end
