module MSFL
  module Validators
    module Definitions
      module HashKey
        def hash_key
          { in: [operators, fields]}
        end

        # Operators still needing parsing: ellipsis2, tilda
        def operators
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