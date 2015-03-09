module MSFL
  module Datasets
    class Base

      include Validators::Definitions::HashKey

      # The descendant class MUST override this method otherwise all field validations will fail
      #
      # @return [Array] the fields in the dataset
      def fields
        raise NoMethodError, "Descendants of MSFL::Datasets::Base are required to implement the #fields method"
      end

      # The descendant class may override this method to control the operators that are supported for the dataset
      #  - Note that this can only be used to reduce the number of supported operators (you can't add new operators
      #    here, without first adding them to MSFL::Validators::Definitions::HashKey#hash_key_operators)
      def operators
        hash_key_operators
      end

      # Method not implemented at this time
      #
      # @param obj [Object] the object that should be type checked based on the field argument
      # @param field [Symbol] which field should the object be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      #
      # @example:
      #  foo.investors_validate_type_conforms("abc", :total_funding) => # there is one more error in errors
      #    # because the type of total_funding must be an integer
      #
      def validate_type_conforms(obj, field, errors)
        errors
      end

      # Method not implemented at this time
      # Returns true if the object conforms to the types supported by the indicated field
      #
      # @param obj [Object] the object that should be type checked based on the field argument
      # @param field [Symbol] which field should the object be checked for conformity
      def type_conforms?(obj, field)
        true
      end

      # Method not implemented at this time
      #
      #
      # @param operator [Symbol] the operator that we want to know if the particular field supports it
      # @param field [Symbol] which field should the operator be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      def validate_operator_conforms(operator, field, errors)
        errors
      end

      # Method not implemented at this time
      #
      #
      # @param value [Object] the precoerced value (the value must be correctly typed)
      #     that should be checked for validity based on the field, if the value does not conform an
      #     exception will be raised
      # @param field [Symbol] which field should the value be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      #
      #
      # @example:
      #  foo.investors_value_conforms(-6000, :total_funding) => # there is one more error in errors
      #    # because the funding cannot be negative
      #
      # @example:
      #  foo.investors_value_conforms(12345, :total_funding) => # errors is unchanged
      #
      def validate_value_conforms(value, field, errors)
        errors
      end
    end
  end
end