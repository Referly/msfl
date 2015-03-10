module MSFL
  module Validators
    module Definitions
      module HashKey

        def valid_hash_key?(key)
          valid_hash_keys.include? key
        end

        def valid_hash_keys
          hash_key_operators.concat self.dataset.fields
        end

        # Operators still needing parsing: ellipsis2, tilda
        def hash_key_operators
          [
              :and,         # logical AND
              :or,          # logical OR
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
      end
    end
  end
end