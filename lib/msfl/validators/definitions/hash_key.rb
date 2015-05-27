module MSFL
  module Validators
    module Definitions
      module HashKey

        def valid_hash_key?(key)
          self.dataset.has_operator?(key) || self.dataset.has_field?(key)
        end

        def valid_hash_keys
          hash_key_operators.concat self.dataset.fields
        end

        # Operators still needing parsing: ellipsis2, tilda
        def hash_key_operators
          binary_operators.concat(logical_operators).concat(partial_operators).concat(foreign_operators)
        end

        def binary_operators
          [
              :in,          # IN
              :between,     # inclusive range for integers, dates, and date times
              :start,       # a range bound inclusively to the left
              :end,         # a range bound inclusively to the right
              :ellipsis2,   # alias to :between
              :tilda,       # alias to :between, :start, and :end depending on usage
              :eq,          # ==
              :lt,          # <
              :lte,         # <=
              :gt,          # >
              :gte,         # >=
              :neg,         # logical negation
          ]
        end

        def partial_operators
          [
              :partial,     # faceted / aggregate
              :given,       # given
              :filter,      # explicit filter
          ]
        end

        def foreign_operators
          [
              :foreign,     # Defines a filter on a related item
              :dataset,     # A foreign dataset
              :filter,      # an explicit filter
          ]
        end

        def logical_operators
          [:and, :or]
        end

        # Returns true if the argument is a valid operator
        #
        # @param symbol [Symbol] the value to check to see if it is an operator
        # @return [Bool] true if the argument is a valid operator, false otherwise
        def operator?(symbol)
          hash_key_operators.include? symbol
        end

        # Returns true if all elements of arr are operators, false otherwise
        #
        # @param arr [Array<Symbol>] the Array of Symbols to be checked against the operators list
        # @return [Bool] true if all of the elements of arr are operators
        def all_operators?(arr)
          arr.each do |e|
            return false unless hash_key_operators.include?(e)
          end
          true
        end


        # Returns true if all elements of arr are logical operators, false otherwise
        #
        # @param arr [Array<Symbol>] and array of symbols to check to see if all elements are logical operators
        # @return [Bool] it is true if all the elements are logical operators, otherwise false
        def all_logical_operators?(arr)
          arr.each do |e|
            return false unless logical_operators.include?(e)
          end
          true
        end

        # Returns true if any of the elements in arr are operators, otherwise false
        #
        # @param arr [Array] the array of elements to check for the presence of operators
        # @return [Bool] true if any of the elements of arr are operators
        def any_operators?(arr)
          arr.each do |e|
            return true if hash_key_operators.include?(e)
          end
          false
        end
      end
    end
  end
end