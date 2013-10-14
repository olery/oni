module Oni
  ##
  # The Daemon class takes care of retrieving work to be processed, scheduling
  # it and dispatching it to a mapper and worker. In essence a Daemon instance
  # can be seen as a controller when compared with typical MVC frameworks.
  #
  # This daemon starts a number of threads (5 by default) that will each
  # perform work on their own using the corresponding mapper and worker class.
  #
  # @!attribute [r] workers
  #  @return [Array<Thread>]
  #
  class Daemon
    include Configurable

    attr_reader :workers

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
      @workers = []

      after_initialize if respond_to?(:after_initialize)
    end

    ##
    # Starts the daemon and waits for all threads to finish execution. This
    # method is blocking since it will wait for all threads to finish.
    #
    # If the current class has a `before_start` method defined it's called
    # before starting the daemon.
    #
    def start
      before_start if respond_to?(:before_start)

      threads.times do
        workers << spawn_thread
      end

      workers.each(&:join)
    end

    ##
    # Terminates all the threads and clears up the list. Note that calling this
    # method acts much like sending a SIGKILL signal to a process: threads will
    # be shut down *immediately*.
    #
    def stop
      workers.each(&:kill)
      workers.clear
    end

    ##
    # Returns the amount of threads to use.
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

    ##
    # Spawns a new thread that waits for daemon input.
    #
    # @return [Thread]
    #
    def spawn_thread
      thread = Thread.new do
        receive { |message| process(message) }
      end

      thread.abort_on_exception = true

      return thread
    end
  end # Daemon
end # Oni
