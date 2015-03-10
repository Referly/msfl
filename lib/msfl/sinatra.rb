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
        MSFL::Parsers::JSON.parse filter.to_json
      end

      # Extracts the dataset name from the Sinatra params. It then returns a new instance of the specified
      # dataset.
      #
      # @param params [Hash] the Sinatra request params
      # @return [MSFL::Datasets::Base, Nil] a new instance of the specified dataset, if it can be found, otherwise nil
      def dataset_from(params)
        dataset_name = params[:dataset].to_sym unless params[:dataset].nil?
        dataset_name ||= nil
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

    module Helpers
      # This method extracts the dataset name and filter from the Sinatra params. It also performs semantic validation
      # of the filter relative to the dataset.
      #
      # The method also has the side effect, when the filter is valid or setting the valid_filter singleton class
      # instance variable valid_filter to the Ruby-ified parsed filter.
      #
      # @param params [Hash] this should be the params variable from the request context
      # @return [Bool] returns true if the filter is valid, false otherwise.
      def msfl_valid?(params)
        Sinatra.validate params
      end

      # This method returns the valid MSFL filter. If the valid filter has already been extracted from the parameters
      # it is returned, otherwise if the optional params argument is specified it will be sent to MSFL::Sinatra.validate
      # and if the validation is successful the valid filter is returned. If the valid filter still cannot be determined
      # then the method raises an ArgumentError.
      #
      # @param params [Hash] optionally pass in the Sinatra request parameters - this is intended to be used when no
      #  previously successful call to msfl_valid? has been made, so that when you just need the filter you can skip
      #  writing msfl_valid?(params) in your code.
      # @return [Object] the Ruby-ified and validated MSFL filter
      def msfl_filter(params = nil)
        filter = Sinatra.valid_filter
        if filter.nil?
          Sinatra.validate params
          filter = Sinatra.valid_filter
        end
        raise ArgumentError, "A valid filter could not be located in msfl_filter." if filter.nil?
        filter
      end
    end

    # Sinatra specific registration hook
    def self.registered(app)
      app.helpers Helpers if app.respond_to?(:helpers)
    end
  end
end