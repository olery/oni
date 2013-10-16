require 'spec_helper'

describe Oni::Worker do
  let :example_worker do
    Class.new(Oni::Worker) do
      def initialize(number = 10)
        @number = number
      end

      def process
        return @number * 2
      end
    end
  end

  example 'raise for the default process method' do
    worker = Oni::Worker.new

    lambda { worker.process }.should raise_error(NotImplementedError)
  end

  example 'set an option of the class' do
    example_worker.set(:number, 10)

    example_worker.new.option(:number).should == 10
  end

  example 'process a job' do
    worker = example_worker.new(10)

    worker.process.should == 20
  end
end
