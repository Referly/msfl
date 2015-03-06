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
        obj = ::MSFL::Types::Set.new obj if obj.is_a?(::Array)
        if obj.respond_to? :each
          obj.each { |key, val| obj[key] = arrays_to_sets val } if obj.is_a?(::Hash)
          obj.map! { |value| arrays_to_sets value } if obj.is_a?(::MSFL::Types::Set)
        end
        obj
      end
    end
  end
end