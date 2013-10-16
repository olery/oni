module Oni
  ##
  # Abstract mapper class that takes care of some common boilerplate code.
  #
  class Mapper
    include Configurable

    ##
    # Remaps the input of the daemon into a format that's easy to use for the
    # worker.
    #
    # @param [Mixed] input
    # @return [Mixed]
    #
    def map_input(input)
      return input
    end

    ##
    # Remaps the output of the working into a format that's easy to use for the
    # daemon layer.
    #
    # @param [Mixed] output
    # @return [Mixed]
    #
    def map_output(output)
      return output
    end
  end # Mapper
end # Oni
