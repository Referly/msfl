require_relative 'definitions'

module MSFL
  module Validators
    class Semantic
      # Load definitions
      include Definitions::HashKey

      attr_accessor :dataset, :errors, :current_field, :current_operator

      BOOLEAN_OPERATORS = [:and, :or]
      ENUMERATION_OPERATORS = [:in]

      def initialize(attributes = nil, opts = {})
        @dataset = MSFL.configuration.datasets.first.new unless MSFL.configuration.datasets.empty?
        @dataset ||= Datasets::Base.new
        @current_field = nil
        @current_operator = nil
      end

      # Returns true if the object is valid, false if the object is invalid
      # An array of hashes of errors is available at #errors
      #
      # This method is not meant to be called recursively, the private method recursive_validate is used
      #  for this purpose
      #
      # @param hash [Hash] the object to be validated
      # @param errors [Array] optionally provide an array that contains errors from previous validators in the
      #  validation chain
      def validate(hash, errors = [], opts = {})
        errors << "Object to validate must be a Hash" unless hash.is_a?(Hash)
        recursive_validate hash, errors, opts
        @errors = errors
        result = true if @errors.empty?
        result ||= false
        result
      end

      # Returns the result of merging errors with any newly encountered errors found in validating the hash
      #
      # @param hash [Hash] the Hash to validate
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @param opts [Hash] the options hash
      # @return [Array] errors merged with any validation errors encountered in validating the hash
      def validate_hash(hash, errors, opts)
        # set current field
        current_field = nil
        # validate the keys and values
        hash.each do |k, value|
          key = k.to_sym
          # validate the current hash key

          # validate that the hash key is supported as an operator or dataset field

          # if they key is an operator validate the dataset supports the operator for the current field
          #
          # if the key is a field of the dataset then we need to validate that the _value_ conforms to the dataset
          #  specific validation rules for that field
          #
          # if they key is neither an operator nor a field we raise an ArgumentError
          #
          # Then make a recursive call to validate on the value so that it and its elements are validated
          #  later I might be able to optimize this by only making the recursive call for Sets and Hashes
          #
          if operators.include? key
            dataset.validate_operator_conforms key, current_field, errors
          elsif dataset.fields.include? key
            current_field = key
            dataset.validate_type_conforms value, current_field, errors
            dataset.validate_value_conforms value, current_field, errors
          else
            errors << "Encountered hash key that is neither an operator nor a property of the dataset"
          end
          recursive_validate value, errors, opts
        end
        errors
      end

      # Acts as a helper method that forwards validation requests for sets to the right handler based on the
      #  :parent_operator option's value
      #
      # @param set [MSFL::Types::Set] the set to validate
      # @param errors [Array] the existing array of validation errors
      # @param opts [Hash] the options hash
      # @return [Array] the errors array argument with any additional validation errors appended
      def validate_set(set, errors, opts)
        error_message =
            "Validate set requires the :parent_operator option be set and represented in either the BOOLEAN_OPERATORS
            or ENUMERATION_OPERATORS constant"
        errors << error_message unless opts.has_key?(:parent_operator)

        if BOOLEAN_OPERATORS.include?(opts[:parent_operator])
          validate_boolean_set set, errors, opts
        elsif ENUMERATION_OPERATORS.include?(opts[:parent_operator])
          validate_enumeration_set set, errors, opts
        else
          errors << error_message
        end
        errors
      end

      # Returns the result of merging errors with any newly encountered errors found in validating the set
      #
      # @param set [MSFL::Types::Set] the set to validate
      # @param errors [Array] an array of validation errors - empty indicates that no errors have been encountered
      # @return [Array] errors merged with any validation errors encountered in validating the set
      def validate_boolean_set(set, errors, opts)
        # Every member needs to be a hash
        set.each do |value|
          errors << "Every member of a boolean set must be a Hash" unless value.is_a?(Hash)
          # recursively call validate on each member
          recursive_validate value, errors, opts
        end
        errors
      end

      # Validates a set of enumerationd scalar values
      def validate_enumeration_set(set, errors, opts)
        current_field = opts[:parent_field] if opts.has_key?(:parent_field)
        current_field ||= nil
        errors << "Validate enumeration set requires the parent_field option to be set" if current_field.nil?
        set.each do |value|
          # this isn't quite right, it feels dirty to use :each
          errors << "No members of an enumeration set may permit iteration across itself" if value.respond_to?(:each)
          dataset.validate_type_conforms value, current_field, errors
          dataset.validate_value_conforms value, current_field, errors
        end
        errors
      end

    private

      def recursive_validate(obj, errors, opts)
        # store a copy of parent_operator and parent_field to restore after recursion
        if obj.is_a?(Hash)
          validate_hash obj, errors, opts
        elsif obj.is_a?(Types::Set)
          validate_set obj, errors, opts
        end
        errors
      end
    end
  end
end