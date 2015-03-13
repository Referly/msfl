require_relative 'msfl/parsers'
require_relative 'msfl/types'
require_relative 'msfl/validators'
require_relative 'msfl/configuration'
require_relative 'msfl/datasets'
require_relative 'msfl/sinatra'

module MSFL
  class << self
    # Allows the user to set configuration options
    #  by yielding the configuration block
    #
    # @param opts [Hash] an optional hash of options, supported options are `reset: true`
    # @param block [Block] an optional configuration block
    # @return [Configuration] the current configuration object
    def configure(opts = {}, &block)
      if opts.has_key?(:reset) && opts[:reset]
        @configuration = nil
      end
      yield(configuration) if block_given?
      configuration
    end

    # Returns the singleton class's configuration object
    #
    # @return [Configuration] the current configuration object
    def configuration
      @configuration ||= Configuration.new
    end
  end
end