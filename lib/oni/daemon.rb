module Oni
  ##
  # The Daemon class takes care of retrieving work to be processed, scheduling
  # it and dispatching it to a mapper and worker. In essence a Daemon instance
  # can be seen as a controller when compared with typical MVC frameworks.
  #
  # @!attribute [r] pool
  #  @return [Oni::ThreadPool]
  #
  class Daemon
    include Configurable

    attr_reader :pool

    ##
    # The default amount of threads to start.
    #
    # @return [Fixnum]
    #
    DEFAULT_THREAD_AMOUNT = 5

    ##
    # Creates a new instance of the class and calls `#after_initialize` if it
    # is defined.
    #
    def initialize
      @pool = ThreadPool.new(threads)

      after_initialize if respond_to?(:after_initialize)
    end

    ##
    # Starts the daemon. Depending on the behaviour of the `#receive` method
    # calling {Oni::Daemon#start} might block execution.
    #
    def start
      pool.start

      receive do |message|
        pool.schedule { process(message) }
      end
    end

    ##
    # Stops the daemon.
    #
    def stop
      pool.stop
    end

    ##
    # Returns the amount of threads to use for the tread pool.
    #
    # @return [Fixnum]
    #
    def threads
      return option(:threads, DEFAULT_THREAD_AMOUNT)
    end

    ##
    # Processes the given message. Upon completion the `#complete` method is
    # called and passed the resulting output.
    #
    # @param [Mixed] message
    #
    def process(message)
      output = run_worker(message)

      complete(output)
    end

    ##
    # Maps the input, runs the worker and then maps the output into something
    # that the daemon can understand.
    #
    # @param [Mixed] message
    # @return [Mixed]
    #
    def run_worker(message)
      mapper = create_mapper
      input  = mapper.map_input(message)
      worker = option(:worker).new
      output = worker.process(input)

      return mapper.map_output(output)
    end

    ##
    # Receives a message, by default this method raises an error.
    #
    # @raise [NotImplementedError]
    #
    def receive
      raise NotImplementedError, 'You must manually implement #receive'
    end

    ##
    # Called when a job has been completed, by default this method is a noop.
    #
    # @param [Mixed] message
    #
    def complete(message)
    end

    ##
    # Creates a new mapper and passes it a set of arguments as defined in
    # {Oni::Daemon#mapper_arguments}.
    #
    # @return [Oni::Mapper]
    #
    def create_mapper
      return option(:mapper).new(mapper_arguments)
    end

    ##
    # Returns the arguments to pass to the mapper as a Hash. By default this
    # method returns an empty Hash.
    #
    # @return [Hash]
    #
    def mapper_arguments
      return {}
    end
  end # Daemon
end # Oni
