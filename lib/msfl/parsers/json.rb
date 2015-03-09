require 'json'
module MSFL
  module Parsers
    class JSON
      def self.parse(json)
        obj = ::JSON.parse(json)
        obj = arrays_to_sets obj
        obj
      end

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