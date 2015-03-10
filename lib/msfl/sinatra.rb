require_relative 'sinatra/helpers'

module MSFL
  module Sinatra
    class << self

      attr_accessor :valid_filter

      def valid_filter
        @valid_filter ||= nil
      end

      # Extracts the filter clause from a Sinatra request params hash and parsers the filter
      #
      # @param params [Hash] the Sinatra request params
      # @return [Object] the Ruby-ified MSFL filter
      def parse_filter_from(params)
        filter = params[:filter]
        MSFL::Parsers::JSON.parse filter.to_json unless filter.nil?
      end

      # Extracts the dataset name from the Sinatra params. It then returns a new instance of the specified
      # dataset.
      #
      # @param params [Hash] the Sinatra request params
      # @return [MSFL::Datasets::Base, Nil] a new instance of the specified dataset, if it can be found, otherwise nil
      def dataset_from(params)
        dataset_name = params[:dataset].to_sym
        Datasets::Base.registered_datasets[dataset_name].new if Datasets::Base.registered_datasets.has_key?(dataset_name)
      end

      # Creates a semantic validator instance that is ready to validate the dataset
      #
      # @param params [Hash] the Sinatra request params
      # @return [MSFL::Validators::Semantic] a validator instance ready to validate filters for the dataset
      def validator_from(params)
        MSFL::Validators::Semantic.new dataset_from(params)
      end

      # Validate the MSFL filter in the Sinatra request's params hash
      #
      # @param params [Hash] the Sinatra request params
      # @return [Bool]
      def validate(params)
        validator = validator_from params
        parsed_filter = parse_filter_from params
        result = validator.validate parsed_filter
        @valid_filter = parsed_filter if result
        result
      end
    end
  end
end