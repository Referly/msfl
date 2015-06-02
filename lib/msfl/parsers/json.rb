require 'json'
module MSFL
  module Parsers
    class JSON

      # Parses json encoded MSFL into Ruby encoded MSFL
      #
      # @param json [String] the string to parse
      # @return [Object] the Ruby encoded MSFL, which may be a Hash, MSFL::Types::Set, or any number of scalar types
      def self.parse(json)
        json_to_parse = json
        json_to_parse = '{}' if json_to_parse.nil? || json_to_parse == "" || json_to_parse == "null"
        obj = ::JSON.parse(json_to_parse)
        obj = arrays_to_sets obj
        obj = convert_keys_to_symbols obj
        obj
      end

      # Converts Ruby Arrays in a partially parsed Ruby MSFL filter to MSFL::Types::Set objects
      #
      # @param obj [Object] the object in which to convert Ruby Array objects to MSFL::Types::Set objects
      # @return [Object] the result of converting Ruby Arrays to MSFL::Types::Set objects
      def self.arrays_to_sets(obj)
        case obj
        when Array
          arrays_to_sets(Types::Set.new obj)
        when Hash
          obj.each_with_object({}) do |(key, val), hash|
            hash[:"#{key}"] = arrays_to_sets val
          end
        when Types::Set
          Types::Set.new obj.map { |value| arrays_to_sets value }
        else
          obj
        end
      end

      # Deeply converts all hash keys to symbols
      #
      # @param obj [Object] the object on which to deeply convert hash keys to symbols
      # @return [Object] the object with its hash keys deeply converted to symbols
      def self.convert_keys_to_symbols(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k,v), hash|
            hash[:"#{k}"] = convert_keys_to_symbols(v)
          end
        when Types::Set
          obj.each_with_object(Types::Set.new) do |item, set|
            set << convert_keys_to_symbols(item)
          end
        when Array
          # Generally this will not be the case as the expectation is that arrays_to_sets has already run
          convert_keys_to_symbols(arrays_to_sets(obj))
        else
          obj
        end
      end
    end
  end
end