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
      def process(number)
        return number * 2
      end
    end

    Class.new(Oni::Daemon) do
      attr_reader :number, :number2, :result

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

      def complete(message)
        @result = message
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

  example 'create the mapper with a set of arguments' do
    daemon = example_daemon.new
    daemon.stub(:mapper_arguments).and_return(:number => 10)

    daemon.create_mapper.number.should == 10
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

    instance.result.should == {:new_number => 20}
  end
end
