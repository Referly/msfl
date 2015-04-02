module MSFL
  module Converters
    class Operator
      include MSFL::Validators::Definitions::HashKey

      # Recursively converts all between operators to equivalent anded gte / lte
      # it currently creates the converted operators into the implied AND format
      #
      # @param obj [Object] the object to recurse through to convert all betweens to gte / ltes
      # @return [Object] the object with betweens converted to anded gte / ltes
      def between_to_gte_lte_recursively(obj)
        result = obj
        if obj.is_a? Hash
          obj.each do |k, v|
            if v.is_a?(Hash) && v.has_key?(:between) && v[:between].has_key?(:start) && v[:between].has_key?(:end)
              lower_bound = between_to_gte_lte_recursively v[:between][:start]
              upper_bound = between_to_gte_lte_recursively v[:between][:end]
              result[k] = { gte: lower_bound, lte: upper_bound  }
            else
              result[k] = between_to_gte_lte_recursively v
            end
          end
        elsif obj.is_a? Types::Set
          result = Types::Set.new
          obj.each do |v|
            result << between_to_gte_lte_recursively(v)
          end
        elsif obj.is_a? Array
          raise ArgumentError, ".convert_between_to_gte_lte requires its argument to have been preprocessed by .arrays_to_sets and .convert_keys_to_symbols"
        end
        result
      end

      # Convert a Hash containing an implict and into an explicit and
      #
      # TYPE 1 --- { make: "chevy", year: 2010 } => { and: [ { make: "chevy" }, { year: 2010 }] }
      # TYPE 2 --- { year: { gte: 2010, lte: 2012 } } => { and: [ { year: { gte: 2010 } }, { year: { lte: 2012 } } ] }
      #
      # @param obj [Object] the Hash that is an implicit and
      # @return [Hash] the resulting explicit hash
      def implicit_and_to_explicit(obj, parent_key = nil)
        result = obj
        if obj.is_a? Hash
          if hash_key_operators.include?(obj.keys.first)
            # the first key an operator
            raise ArgumentError, "#implicit_and_to_explicit requires that all or none of a hash's keys be operators" unless all_operators?(obj.keys)
            # all keys are operators
            raise ArgumentError, "#implicit_and_to_explicit requires that parent_key be specified when converting operators" if parent_key.nil?
            # parent key is non nil
            and_array = []
            obj.each do |k, v|
              and_array << { parent_key => { k => implicit_and_to_explicit(v, k) } }
            end
          else
            # the first key is not an operator
            raise ArgumentError, "#implicit_and_to_explicit requires that all or none of a hash's keys be operators" if any_operators?(obj.keys)
            # none of the keys are operators
            and_array = []
            obj.each do |k, v|
              if v.is_a? Hash
                and_array << implicit_and_to_explicit(v, k)
              else
                and_array << { k => v }
              end
            end
          end
          result = { and: MSFL::Types::Set.new(and_array) }
        end
        result
      end

      def implicit_and_to_explicit_recursively(obj)

      end

    private
      # Use this method for converting implicit and hashes to explicit ones when the keys are operators
      def implicit_to_explicit_for_ops(hash)
        and_array = []
        field = hash.keys.first
        if hash[field].is_a? Hash
          hash[field].each do |k, v|
            and_array << { field => { k => v } }
          end
        end
        { and: MSFL::Types::Set.new(and_array) }
      end

      # Use this method for converting implicit and hashes to explicit ones when the keys are properties
      def implicit_to_explicit_for_field(hash)
        and_array = []
        hash.each { |key, value| and_array << { key => value } }
        { and: MSFL::Types::Set.new(and_array) }
      end
    end
  end
end
