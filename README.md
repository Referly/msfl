[![Circle CI](https://circleci.com/gh/Referly/msfl.svg?style=svg)](https://circleci.com/gh/Referly/msfl)

# Ruby Gem for the Mattermark Semantic Filter Language

Contains serializers and validators (and perhaps other) MSFL goodies

## EBNF

MSFL is a context-free language. The context-free grammar is defined below.

TODO add foreign_expr

    # EXPRESSIONS

    filter          =   lc , { filter_expr } , rc ;

    filter_expr     =   range_expr
                    |   binary_expr
                    |   set_expr
                    |   partial_expr ;

    range_expr      =   between ;

    binary_expr     =   comparisons
                    |   containment ;

    set_expr        =   and
                    |   or ;

    partial_expr    =   partial_op , colon , partial ;

    partial         =   lc , given_expr , comma , partial_filter , rc ;

    given_expr      =   given_op , colon, filter ;

    partial_filter  =   filter_op , colon , filter ;

    between         =   value , colon , start_end
                    |   value , colon , between_body ;

    comparisons     =   comparison , { comma , comparison } ;

    containment     =   word , colon , in_expr ;

    and             =   and_op , colon , filters ;

    or              =   or_op , colon , filters ;

    comparison      =   word , colon , value
                    |   word , colon , lc , comparison_list , rc ;

    comparison_list =   comparison_expr , { comma , comparison_expr } ;

    comparison_expr =   comparison_op , colon , value ;

    in_expr         =   lc , in_op , colon , values , rc ;

    filters         =   ls , { filter } , rs ;

    values          =   ls , { value } , rs ;

    between_body    =   lc , between_op , colon , start_end , rc ;

    start_end       =   lc , start_expr , comma , end_expr , rc ;

    start_expr      =   start_op , colon , range_value ;

    end_expr        =   end_op , colon , range_value ;



    # OPERATORS

    partial_op      =   dq , "partial" , dq ;

    given_op        =   dq , "given" , dq ;

    filter_op       =   dq , "filter" , dq ;

    in_op           =   dq , "in" , dq ;

    between_op      =   dq , "between" , dq ;

    start_op        =   dq , "start" , dq ;

    end_op          =   dq , "end" , dq ;

    comparison_op   =   lt_op
                    |   gt_op
                    |   lte_op
                    |   gte_op
                    |   eq_op ;

    lt_op           =   dq , "lt" , dq ;

    gt_op           =   dq , "gt" , dq ;

    lte_op          =   dq , "lte" , dq ;

    gte_op          =   dq , "gte" , dq ;

    eq_op           =   dq , "eq" , dq ;

    and_op          =   dq , "and" , dq ;

    or_op           =   dq , "or" , dq ;



    # VALUES AND TYPES

    range_value     =   number
                    |   date
                    |   datetime
                    |   time ;

    value           =   word
                    |   range_value
                    |   boolean ;

    word            =   dq , character , { character } , dq ;

    number          =   integer | decimal ;

    integer         =   [ hyphen ] , digit , { digit } ;

    decimal         =   integer
                    |   { integer } , dot , { digit } ;

    boolean         =   true | false ;

    true            =   "true"
                    |   dq , "true" , dq
                    |   "1"
                    |   dq , "1" , dq ;

    false           =   "false"
                    |   dq , "false" , dq
                    |   "0"
                    |   dq , "0" , dq ;

    date            =   ? ISO 8601 date format http://en.wikipedia.org/wiki/ISO_8601 ? ;

    datetime        =   ? ISO 8601 combined date and time format http://en.wikipedia.org/wiki/ISO_8601 ? ;

    time            =   ? ISO 8601 time format http://en.wikipedia.org/wiki/ISO_8601 ? ;

    character       =   letter
                    |   digit
                    |   symbol ;

    letter          =   "A" | "B" | "C" | "D" | "E" | "F" | "G"
                    |   "H" | "I" | "J" | "K" | "L" | "M" | "N"
                    |   "O" | "P" | "Q" | "R" | "S" | "T" | "U"
                    |   "V" | "W" | "X" | "Y" | "Z"
                    |   "a" | "b" | "c" | "d" | "e" | "f" | "g"
                    |   "h" | "i" | "j" | "k" | "l" | "m" | "n"
                    |   "o" | "p" | "q" | "r" | "s" | "t" | "u"
                    |   "v" | "w" | "x" | "y" | "z" ;

    digit           =   "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

    symbol          =   "'" | "~" | "." | "_" | "-" | ":" | "?" | "/" | "=" | "@" | "&" ;

    left_curly      =   "{" ;

    lc              =   left_curly ;

    right_curly     =   "}" ;

    rc              =   right_curly ;

    left_square     =   "[" ;

    ls              =   left_square ;

    right_square    =   "]" ;

    rs              =   right_square ;

    comma           =   "," ;

    hyphen          =   "-" ;

    colon           =   ":" ;

    double_quote    =   '"' ;

    dq              =   double_quote ;

    dot             =   "." ;




## Configuration

All configuration options should be set in a block passed to `MSFL.configure { |c| c.datasets = [] }`

Naturally you should provide an appropriate array of the datasets you are supporting.

As additional configuration settings are added they will be set similarly.

## Converters

The MSFL converters provide convenience methods for transforming a parsed MSFL tree to a different structure that is
logically equivalent. The intent is to enable consumers of MSFL to easily manipulate parsed MSFL filters into the form
that most easily or efficiently allows adaptation to the storage mechanism upon which the filtering is being effected.

Note that the order in which converters are run is controlled by the constant MSFL::Converters::CONVERSIONS and cannot
be manipulated through configuration. This behavior is currently necessary for ease of implementation but is unlikely
to continue to be status quo.

## Datasets

The consumer of the MSFL gem defines one or more datasets. The dataset definition enumerates the supported fields and
their types.

## Parsers

Currently there is only a parser for the JSON encoding of MSFL filters. Any additional parsers will also be placed
under this directory.

## Types

Because of the behavioral limitations imposed on certain types (currently Sets are the only example) there is a folder
for types to be defined.

## Validators

After parsing a MSFL filter it can be validated. Currently the validation is primitive. The intent is to enable
semantic validation on a per dataset basis. This will allow per attribute validations to be setup by the consumer
of this gem, which will be run automatically during validation.

## Frameworks

### Sinatra

There are several helper methods for using this gem with Sinatra. You can register the helpers in your Sinatra app
by adding the following inside of your application's class.

```
# This should actually be Sinatra::MSFL but there are some namespacing issues with MSFL currently that prevented
# this from being the v0 implementation. This will change in the near future.
register MSFL::Sinatra
```