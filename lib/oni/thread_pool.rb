require 'thread'

module Oni
  ##
  # A basic thread pool class inspired by the Puma thread pool class.
  #
  # @!attribute [r] amount
  #  @return [Numeric] The amount of threads to run, set to 10 by default.
  #
  # @!attribute [r] queue
  #  @return [Queue]
  #
  # @!attribute [r] threads
  #  @return [Array]
  #
  class ThreadPool
    attr_reader :amount, :queue, :threads

    ##
    # @param [Numeric] amount
    #
    def initialize(amount = 10)
      @amount  = amount
      @queue   = ::Queue.new
      @threads = []
    end

    ##
    # Starts the thread pool.
    #
    def start
      amount.times { threads << spawn_thread }
    end

    ##
    # Schedules the termination of all threads and waits for them to finish.
    #
    def stop
      amount.times do
        schedule { throw :terminate }
      end

      threads.each(&:join)
      threads.clear
      queue.clear
    end

    ##
    # Schedules the given block to be executed in one of the thread pool
    # workers.
    #
    # @example
    #  schedule do
    #    puts 'Something something thread safety'
    #  end
    #
    # @param [#call] block The object to schedule. The object must respond to
    #  `#call` (e.g. Procs).
    #
    def schedule(&block)
      unless block_given?
        raise LocalJumpError, 'You must specify a block to schedule'
      end

      queue << block
    end

    private

    ##
    # Spawns a single thread.
    #
    def spawn_thread
      return Thread.new do
        catch :terminate do
          loop { queue.pop.call }
        end
      end
    end
  end # ThreadPool
end # Oni
