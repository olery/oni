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

    ##
    # Method for returning (optional) extra data that should be sent to
    # {Oni::Daemon#error} upon encountering an error. This method can be used
    # to for example return the mapped input so that it can be sent to Rollbar.
    #
    # @example
    #  def extra_error_data
    #    return {:user_id => current_user.id}
    #  end
    #
    # @return [Mixed]
    #
    def extra_error_data
    end
  end # Worker
end # Oni
