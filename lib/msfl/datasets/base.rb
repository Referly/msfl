module MSFL
  module Datasets
    # This is a fake data set definition that shows the structure for composing your own
    class Base

      #
      #
      # @param obj [Object] the object that should be type checked based on the property argument
      # @param property [Symbol] which property should the object be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      #
      # @example:
      #  foo.investors_validate_type_conforms("abc", :total_funding) => # there is one more error in errors
      #    # because the type of total_funding must be an integer
      #
      def validate_type_conforms(obj, property, errors)
        errors << "Type of #{obj} does not conform to #{property}" unless type_conforms?(obj, property)
        errors
      end

      # Returns true if the object conforms to the types supported by the indicated property
      #
      # @param obj [Object] the object that should be type checked based on the property argument
      # @param property [Symbol] which property should the object be checked for conformity
      def type_conforms?(obj, property)
        field_type_map[property.to_sym].each { |permitted_type| return true if obj.is_a?(permitted_type) }
        false
      end

      #
      #
      # @param operator [Symbol] the operator that we want to know if the particular property supports it
      # @param property [Symbol] which property should the operator be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      def validate_operator_conforms(operator, property, errors)
        errors
      end

      #
      #
      # @param value [Object] the precoerced value (the value must be correctly typed)
      #     that should be checked for validity based on the property, if the value does not conform an
      #     exception will be raised
      # @param property [Symbol] which property should the value be checked for conformity
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
      def validate_value_conforms(value, property, errors)
        raise ArgumentError, "Value must be coerced to type of #{property} before the value can be validated." unless investors_type_conforms?(value, property)
        errors
      end
    end
  end
end