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
        obj
      end

      # Converts Ruby Arrays is a partially parsed Ruby MSFL filter to MSFL::Types::Set objects
      #
      # @param obj [Object] the object in which to convert Ruby Array objects to MSFL::Types::Set objects
      # @return [Object] the result of converting Ruby Arrays to MSFL::Types::Set objects
      def self.arrays_to_sets(obj)
        obj = Types::Set.new obj if obj.is_a?(::Array)
        if obj.respond_to? :each
          if obj.is_a?(::Hash)
            result = {}
            obj.each { |key, val| result[key.to_sym] = arrays_to_sets val }
          elsif obj.is_a?(Types::Set)
            result = Types::Set.new obj.map { |value| arrays_to_sets value }
          end
        end
        result ||= obj
        result
      end
    end
  end
end