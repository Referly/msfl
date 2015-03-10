module MSFL
  # This module is intented to be registered with a Sinatra application.
  # It binds some convenience methods that are Sinatra specific to the request context in a Sinatra application.
  #
  # Usage
  #
  # In your Sinatra application in the app context call
  #   `register MSFL::Sinatra`
  module Sinatra

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
