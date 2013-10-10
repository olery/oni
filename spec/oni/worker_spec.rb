require 'spec_helper'

describe Oni::Worker do
  let :example_worker do
    Class.new(Oni::Worker) do
      attr_reader :example

      def process(message)
        return message * 2
      end
    end
  end

  example 'raise for the default process method' do
    worker = Oni::Worker.new

    lambda { worker.process(10) }.should raise_error(NotImplementedError)
  end

  example 'set an option of the class' do
    example_worker.set(:number, 10)

    example_worker.new.option(:number).should == 10
  end

  example 'set attributes using the constructor' do
    instance = example_worker.new(:example => 20)

    instance.example.should == 20
  end

  example 'process a job' do
    worker = example_worker.new

    worker.process(10).should == 20
  end
end
