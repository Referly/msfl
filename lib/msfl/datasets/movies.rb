module MSFL
  module Datasets
    # This is a fake data set definition that shows the structure for composing your own
    class Movies < Base

      def field_type_map
        {
          name: [String],
        }
      end

      def field_operator_map
        {
            name: [:in, :eq]
        }
      end
    end
  end
end