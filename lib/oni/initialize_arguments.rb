module Oni
  ##
  # The InitializeArguments mixin can be used to create a constructor that
  # takes a Hash as its argument and sets the values as instance variables.
  #
  # Basic usage:
  #
  #     class MyClass
  #       include Oni::InitializeArguments
  #
  #       attr_reader :number
  #     end
  #
  #     instance = MyClass.new(:number => 10)
  #     instance.number # => 10
  #
  module InitializeArguments
    ##
    # Creates an instance of the including class and sets the options passed in
    # the Hash as instance variables. Options are only set if a corresponding
    # getter is defined.
    #
    # @param [Hash] options
    #
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end
    end
  end # InitializeArguments
end # Oni
