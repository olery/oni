module Oni
  ##
  # An abstract worker class that takes care of some common boilerplate code.
  #
  class Worker
    include Configurable

    ##
    # Runs the worker and returns some kind of output.
    #
    # @return [Mixed]
    # @raise [NotImplementedError]
    #
    def process
      raise NotImplementedError, 'You must implement #process yourself'
    end
  end # Worker
end # Oni
