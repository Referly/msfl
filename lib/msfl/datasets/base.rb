module MSFL
  module Datasets
    class Base

      include Validators::Definitions::HashKey

      # The descendant class MUST override this method otherwise all field validations will fail
      #
      # The method defines an array of symbols, indicating what fields are supported for the Dataset
      #
      # @return [Array<Symbol>] the fields in the dataset
      def fields
        raise NoMethodError, "Descendants of MSFL::Datasets::Base are required to implement the #fields method"
      end

      # The descendant class may override this method to control the operators that are supported for the dataset
      #  - Note that this can only be used to reduce the number of supported operators (you can't add new operators
      #    here, without first adding them to MSFL::Validators::Definitions::HashKey#hash_key_operators)
      #
      # @return [Array<Symbol>] the operators supported in the dataset
      def operators
        hash_key_operators
      end

      # This method returns the errors argument. The errors argument is unchanged if type conformity validation passes,
      # otherwise an error is added to errors.
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
        errors << "Dataset type conformity validation failed for obj: #{obj} against field: #{field}" unless type_conforms?(obj, field)
        errors
      end

      # Method not implemented at this time
      # Returns true if the object conforms to the types supported by the indicated field
      # While not currently implemented the intent is that the descendant Dataset would specify a hash of supported
      # types for each field and this method would then cross reference that list.
      #
      # @param obj [Object] the object that should be type checked based on the field argument
      # @param field [Symbol] which field should the object be checked for conformity
      def type_conforms?(obj, field)
        true
      end

      # This method returns the errors argument. The errors argument is unchanged if operator conformity validation
      # passes, otherwise an error is added to errors.
      #
      # @param operator [Symbol] the operator that we want to know if the particular field supports it
      # @param field [Symbol] which field should the operator be checked for conformity
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      def validate_operator_conforms(operator, field, errors)
        errors << "Dataset operator conformity validation failed for operator: #{operator} against field: #{field}" unless operator_conforms?(operator, field)
        errors
      end

      # Method not implemented at this time
      #
      # This method returns true if the operator is supported for the specified field by the dataset. While this
      # is not currently implemented, the intent is that a hash of fields (as keys) would map to
      # Arrays<Symbol> (as values) and then this method would validate that the operator argument meets this contract.
      #
      # @param operator [Symbol] the operator that needs to be checked for conformity
      # @param field [Symbol] which field should the operator be checked against
      # @return [Bool] true if the operator conforms, false otherwise
      def operator_conforms?(operator, field)
        true
      end

      # This method returns the errors argument. The errors argument is unchanged if value conformity validation
      # passes, otherwise an error is added to errors.
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
        errors << "Dataset value conformity validation failed for value: #{value} against field: #{field}" unless value_conforms?(value, field, errors)
        errors
      end

      # Method not implemented at this time
      #
      # This method returns true if the value is supported for the specified field by the dataset. While this is not
      # currently implemented, the intent is that a hash of fields (as keys) would map to an Array of validation
      # constraints. These constraints would then be executed against the value and if all are successful the value
      # would be considered to have passed.
      #
      # It is likely that the methods invoked from the Array of validation constraints would actually return an Array
      # of errors encountered, this method would then concat that Array into the errors array. If the encountered errors
      # array is empty the method would return true, and false otherwise.
      #
      # @param value [Object] the object to on which to perform validation
      # @param field [Symbol] the field the object should be validated against
      # @param errors [Array] the array of errors from prior validations
      # @return [Bool] true if no new errors are encountered, false otherwise
      def value_conforms?(value, field, errors = [])
        true
      end
    end
  end
end