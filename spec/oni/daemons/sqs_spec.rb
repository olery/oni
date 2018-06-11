require 'spec_helper'
require_relative '../../../lib/oni/daemons/sqs'

describe Oni::Daemons::SQS do
  let :example_daemon do
    Class.new(Oni::Daemons::SQS)
  end

  example 'require the queue name to be set' do
    block = lambda { example_daemon.new }

    block.should raise_error(ArgumentError, /The option queue_name is required/)
  end

  example 'receive a message' do
    example_daemon.set(:queue_name, 'example')

    instance = example_daemon.new
    queue    = Class.new do
      def poll options = {}
        if options[:max_number_of_messages] and options[:max_number_of_messages] > 1
          yield [1,2,3]
        else
          yield [10]
        end
      end
    end

    instance.stub(:queue).and_return(queue.new)

    instance.receive do |number|
      number.should == 10
    end
  end
end
