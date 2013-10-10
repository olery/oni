module Oni
  ##
  # An abstract worker class that takes care of some common boilerplate code.
  #
  class Worker
    include Configurable
    include InitializeArguments

    ##
    # Processes the given message and returns some kind of output.
    #
    # @param [Mixed] message
    # @return [Mixed]
    #
    def process(message)
      raise NotImplementedError, 'You must implement #process yourself'
    end
  end # Worker
end # Oni
