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

    attr_reader :daemon_workers

    ##
    # The default amount of worker to start.
    #
    # @return [Fixnum]
    #
    DEFAULT_WORKER_AMOUNT = 1

    ##
    # The default amount of threads to start.
    #
    # @return [Fixnum]
    #
    DEFAULT_THREAD_AMOUNT = 5

    ##
    # The default amount of threads to start.
    #
    # @return [Fixnum]
    #
    DEFAULT_WORKER_TIMEOUT = nil

    ##
    # Creates a new instance of the class and calls `#after_initialize` if it
    # is defined.
    #
    def initialize
      @daemon_workers = Hash.new{ |h, k| h[k] = [] }

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
      before_start if respond_to? :before_start

      wthreads = if threads <= 1    then [run_thread]
                 elsif workers <= 1 then standard_worker
                 else wthreads = Array.new(workers).map{ |i| spawn_worker i } end

      after_start if respond_to? :after_start

      %i[INT TERM].each{ |sig| trap(sig){ stop } }
      wthreads.each(&:join) if workers > 1

    rescue => error
      error(error)
    end

    ##
    # Terminates all the threads and clears up the list. Note that calling this
    # method acts much like sending a SIGKILL signal to a process: threads will
    # be shut down *immediately*.
    #
    def stop
      daemon_workers.each do |pid, worker_threads|
        worker_threads.each(&:kill)
        worker_threads.clear
      end
    end

    def workers
      option :workers, DEFAULT_WORKER_AMOUNT
    end

    ##
    # Returns the amount of threads to use.
    #
    # @return [Fixnum]
    #
    def threads
      option :threads, DEFAULT_THREAD_AMOUNT
    end

    ##
    # Returns the amount of threads to use.
    #
    # @return [Fixnum]
    #
    def worker_timeout
      option :worker_timeout, DEFAULT_WORKER_TIMEOUT
    end

    ##
    # Processes the given message. Upon completion the `#complete` method is
    # called and passed the resulting output.
    #
    # @param [Mixed] message
    #
    def process(message)
      output = run_worker(message)

      complete(message, output)
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
      worker = option(:worker).new(*input)
      output = Timeout.timeout worker_timeout do
        worker.process
      end

      mapper.map_output output
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
    # This method is passed 2 arguments:
    #
    # 1. The raw input message.
    # 2. The output of the worker (remapped by the mapper).
    #
    # @param [Mixed] message The raw input message (e.g. an AWS SQS message)
    # @param [Mixed] output The output of the worker.
    #
    def complete(message, output)
    end

    ##
    # Called whenever an error is raised in the daemon, mapper or worker. By
    # default this method just re-raises the error.
    #
    # @param [StandardError] error
    #
    def error(error)
      raise error
    end

    ##
    # Creates a new mapper and passes it a set of arguments as defined in
    # {Oni::Daemon#mapper_arguments}.
    #
    # @return [Oni::Mapper]
    #
    def create_mapper
      unless option(:mapper)
        raise ArgumentError, 'No mapper has been set in the `:mapper` option'
      end

      return option(:mapper).new
    end

    ##
    # Spawns a new thread that waits for daemon input.
    #
    # @return [Thread]
    #
    def spawn_worker i = nil, &block
      Thread.new do
        loop do # keep restarting for OOM and other cases
          pid = fork do
            Process.setproctitle "#{$0}: worker #{i}" if i

            if block then yield else standard_worker end
          end
          Process.wait pid
        end
      end
    end

    def standard_worker
      Array.new(threads).map do
        spawn_thread.tap{ |t| daemon_workers[Process.pid] << t }
      end.each(&:join)
    end

    ##
    # Spawns a new thread that waits for daemon input.
    #
    # @return [Thread]
    #
    def spawn_thread
      Thread.new{ run_thread }.tap do |t|
        t.abort_on_exception = true
      end
    end

    ##
    # The main code to execute in individual threads.
    #
    # If an error occurs in the receive method or processing a job the error
    # handler is executed and the process is retried. It's the responsibility
    # of the `error` method to determine if the process should fail only once
    # (and fail hard) or if it should continue running.
    #
    def run_thread
      receive do |message|
        process message
      end
    rescue => error
      error(error)

      retry
    end

  end
end
