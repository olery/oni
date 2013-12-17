module Oni
  ##
  # Error class that can be used to wrap existing errors and attach extra data
  # to them. This class is primarily intended to be used within workers to
  # attach the input to the error.
  #
  # @!attribute [r] original_error
  #  @return [StandardError]
  #
  # @!attribute [r] parameters
  #  @return [Mixed]
  #
  class WrappedError < StandardError
    attr_reader :original_error, :parameters

    ##
    # Wraps an existing error.
    #
    # @param [StandardError] error
    # @param [Mixed] parameters
    # @return [Oni::WrappedError]
    #
    def self.from(error, parameters = nil)
      return new(
        error.message,
        :original_error => error,
        :parameters     => parameters
      )
    end

    ##
    # @param [String] message
    # @param [Hash] options
    #
    def initialize(message = nil, options = {})
      super(message)

      options.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end
    end
  end # WrappedError
end # Oni
