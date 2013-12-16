require 'spec_helper'

describe Oni::Daemon do
  let :example_daemon do
    mapper = Class.new(Oni::Mapper) do
      attr_reader :number

      def map_input(input)
        return input[:number]
      end

      def map_output(number)
        return {:new_number => number}
      end
    end

    worker = Class.new(Oni::Worker) do
      def initialize(number)
        @number = number
      end

      def process
        return @number * 2
      end

      def extra_error_data
        return @number
      end
    end

    Class.new(Oni::Daemon) do
      attr_reader :number, :number2, :message, :output, :timings

      set :mapper, mapper
      set :worker, worker
      set :threads, 2

      def after_initialize
        @number = 10
      end

      def before_start
        @number2 = 20
      end

      def receive
        yield({:number => 10})
      end

      def error(error, extra_data = nil)
        raise "#{error.message}: #{extra_data}"
      end

      def complete(message, output, timings)
        @message = message
        @output  = output
        @timings = timings
      end
    end
  end

  example 'call #after_initialize' do
    example_daemon.new.number.should == 10
  end

  example 'call #before_start' do
    daemon = example_daemon.new
    daemon.start
    daemon.stop

    daemon.number2.should == 20
  end

  example 'raise for the default receive method' do
    daemon = Oni::Daemon.new

    lambda { daemon.receive }.should raise_error(NotImplementedError)
  end

  example 'return the amount of threads to use' do
    example_daemon.set(:threads, 10)

    example_daemon.new.threads.should == 10
  end

  example 'use the default amount of threads' do
    example_daemon.set(:threads, nil)

    example_daemon.new.threads.should == Oni::Daemon::DEFAULT_THREAD_AMOUNT
  end

  example 'create the mapper without any arguments' do
    mapper = example_daemon.new.create_mapper

    mapper.is_a?(Oni::Mapper).should == true
    mapper.number.nil?.should        == true
  end

  example 'start and stop the thread daemon' do
    instance = example_daemon.new
    instance.start

    instance.workers.length.should == instance.threads

    instance.stop

    instance.workers.length.should == 0
  end

  example 'process a job' do
    instance = example_daemon.new

    instance.start
    instance.stop

    instance.message.should == {:number => 10}
    instance.output.should  == {:new_number => 20}
  end

  example 'measure the execution time' do
    instance = example_daemon.new

    instance.start
    instance.stop

    instance.timings.is_a?(Benchmark::Tms).should == true
  end

  context 'error handling' do
    let :example_daemon do
      Class.new(Oni::Daemon) do
        set :threads, 0

        def receive
          yield 10
        end
      end
    end

    let :custom_error_daemon do
      Class.new(example_daemon) do
        set :threads, 0

        def error(error, extra_data = nil)
          raise 'custom error'
        end
      end
    end

    example 'should raise by default' do
      daemon = example_daemon.new

      lambda { daemon.start }.should raise_error(ArgumentError)
    end

    example 'allow custom error callbacks' do
      daemon = custom_error_daemon.new

      lambda { daemon.start }.should raise_error(RuntimeError, 'custom error')
    end
  end

  context 'error handling with extra data' do
    example 'include the extra data' do
      instance = example_daemon.new

      instance.option(:worker).any_instance.stub(:process) { raise 'example' }

      block = lambda { instance.run_worker(:number => 10) }

      block.should raise_error(RuntimeError, 'example: 10')
    end
  end
end
