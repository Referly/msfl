module MSFL
  module Converters
    class Operator
      include MSFL::Validators::Definitions::HashKey

      # Order is respected by run_conversions
      # in otherwords run_conversions executes conversions in the order they occur
      # in CONVERSIONS, not in the order in which they are passed into the method
      #
      # conversion order is context-free
      CONVERSIONS = [
          :implicit_between_to_explicit_recursively,
          :between_to_gte_lte_recursively,
          :implicit_and_to_explicit_recursively
      ]

      # Runs conversions on an object
      # It respects the order of CONVERSIONS, not the order of elements in conversions_to_run
      #
      # @param obj [Object] the object to run the conversions on
      # @param conversions_to_run [Array<Symbol>] an array of the conversions that should be run, duplicates are ignored
      # @return [Object] the object with the conversions applied
      def run_conversions(obj, conversions_to_run = nil)
        conversions_to_run ||= CONVERSIONS
        unless all_conversions?(conversions_to_run)
          raise ArgumentError, "#run_conversions second argument is optional, if specified it must be an Array of Symbols"
        end
        result = obj
        CONVERSIONS.each do |conv|
          # In the order that items are in CONVERSIONS run all of the conversions_to_run
          result = send(conv, result) if conversions_to_run.include?(conv)
        end
        result
      end



      # { year: { start: 2001, end: 2005 } }
      #  => { year: { between: { start: 2001, end: 2015 } } }
      def implicit_between_to_explicit_recursively(obj)
        if obj.is_a? Hash
          # if the hash has two keys :start and :end, nest it inside a between and recurse on the values
          if obj.has_key?(:start) && obj.has_key?(:end)
            result = { between: { start: implicit_between_to_explicit_recursively(obj[:start]), end: implicit_between_to_explicit_recursively(obj[:end]) } }
          else
            result = Hash.new
            obj.each do |k, v|
              result[k] = implicit_between_to_explicit_recursively(v)
            end
          end
        elsif obj.is_a? Types::Set
          result = recurse_through_set :implicit_between_to_explicit_recursively, obj
        elsif obj.is_a? Array
          raise ArgumentError, "#implicit_between_to_explicit_recursively requires that it does not contain any Arrays - its argument should preprocessed by .arrays_to_sets and .convert_keys_to_symbols"
        end
        result ||= obj
      end

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
          result = recurse_through_set :between_to_gte_lte_recursively, obj
        elsif obj.is_a? Array
          raise ArgumentError, "#between_to_gte_lte requires that it does not contain any Arrays - its argument should preprocessed by .arrays_to_sets and .convert_keys_to_symbols"
        end
        result
      end

      # Convert a Hash containing an implict and into an explicit and
      #
      # TYPE 1 ---
      #     { make: "chevy", year: 2010 }
      #      =>    { and: [ { make: "chevy" }, { year: 2010 }] }
      # TYPE 2 ---
      #     { year: { gte: 2010, lte: 2012 } }
      #      => { and: [ { year: { gte: 2010 } }, { year: { lte: 2012 } } ] }
      #
      # TYPE 3 ---
      #     { make: "chevy", year: { gte: 2010, lte: 2012 } }
      #      => { and: [ { make: "chevy" }, { and: [ { year: { gte: 2010 } }, { year: { lte: 2012 } } ] } ] }
      #
      # @param obj [Object] the Hash that is an implicit and
      # @return [Hash] the resulting explicit hash
      def implicit_and_to_explicit_recursively(obj, parent_key = nil)
        if obj.is_a? Hash
          first_key = obj.keys.first
          if binary_operators.include?(first_key)
            result = i_to_e_bin_op obj, parent_key
          elsif logical_operators.include?(first_key)
            result = i_to_e_log_op obj, parent_key
          else
            # the first key is not an operator
            # if there is only one key just assign the result of calling this method recursively on the value to the result for the key
            if obj.keys.count == 1
              if obj[first_key].is_a?(Hash)
                result = implicit_and_to_explicit_recursively obj[first_key], first_key
              elsif obj[first_key].is_a? MSFL::Types::Set
                # This situation occurs when there are nested logical operators
                # obj is a hash, with one key that is not a binary operator which has a value that is a MSFL::Types::Set
                result = Hash.new
                result[first_key] = recurse_through_set :implicit_and_to_explicit_recursively, obj[first_key]
              elsif obj[first_key].is_a? Array
                raise ArgumentError, "#implicit_and_to_explicit requires that it does not contain any Arrays - its argument should preprocessed by .arrays_to_sets and .convert_keys_to_symbols"
              end
            else
              raise ArgumentError, "#implicit_and_to_explicit requires that all or none of a hash's keys be operators" if any_operators?(obj.keys)
              # none of the keys are operators
              and_array = []
              obj.each do |k, v|
                if v.is_a? Hash
                  and_array << implicit_and_to_explicit_recursively(v, k)
                else
                  and_array << { k => v }
                end
              end
              result = { and: MSFL::Types::Set.new(and_array) }
            end
          end
        elsif obj.is_a? MSFL::Types::Set
          result = i_to_e_set obj, parent_key
        elsif obj.is_a? Array
          raise ArgumentError, "#implicit_and_to_explicit requires that it does not contain any Arrays - its argument should preprocessed by .arrays_to_sets and .convert_keys_to_symbols"
        end
        result ||= obj
      end

    private
      # Recursively handle a hash containing keys that are all logical operators
      def i_to_e_log_op(hash, parent_key = nil)
        raise ArgumentError, "#implicit_and_to_explicit requires that all or none of a hash's keys be logical operators" unless all_logical_operators?(hash.keys)
        result = {}
        hash.each do |key, value|
          result[key] = implicit_and_to_explicit_recursively value
        end
        result
      end

      # Recursively handle a hash containing keys that are all binary operators
      def i_to_e_bin_op(hash, parent_key = nil)
        # the first key an operator
        raise ArgumentError, "#implicit_and_to_explicit requires that all or none of a hash's keys be operators" unless all_operators?(hash.keys)
        # all keys are operators
        first_key = hash.keys.first
        if hash.keys.count == 1
          # There's only one key so there cannot be an implied AND at this level
          if parent_key && (! binary_operators.include?(parent_key)) # this needs more testing - I'm not entirely sure if I should check for this esoteric case of immediately nested explicit ANDs inside of an implied AND
            # The parent_key argument was provided which means that the caller expects the result to be a hash of at least two levels
            # where the first level has a key of the parent_key with a value of a hash
            # first_key is passed in the recursive call
            { parent_key => { first_key => implicit_and_to_explicit_recursively(hash[first_key], first_key)}}
          else
            { first_key => implicit_and_to_explicit_recursively(hash[first_key]) }
          end
        else
          raise ArgumentError, "#implicit_and_to_explicit requires that parent_key be specified when converting operators" if parent_key.nil?
          # parent key is non nil
          and_array = []
          hash.each do |k, v|
            and_array << { parent_key => { k => implicit_and_to_explicit_recursively(v, k) } }
          end
          { and: MSFL::Types::Set.new(and_array) }
        end
      end

      def i_to_e_set(set, parent_key = nil)
        recurse_through_set :implicit_and_to_explicit_recursively, set
      end

      def recurse_through_set(method, set)
        result = MSFL::Types::Set.new
        set.each do |v|
          result << send(method, v)
        end
        result
      end

      # Returns true if the argument is an Array of Symbols, otherwise false
      #
      # @param obj [Obj] the object to check
      # @return [Bool] true if the argument is an Array of Symbols
      def all_conversions?(obj)
        return false unless obj.is_a?(Array)
        obj.each do |v|
          return false unless v.is_a?(Symbol)
        end
        true
      end
    end
  end
end
