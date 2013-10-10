require 'spec_helper'

describe Oni::Configurable do
  let :example_class do
    Class.new do
      include Oni::Configurable
    end
  end

  example 'setting an option' do
    example_class.set(:number, 10)

    example_class.options[:number].should == 10
  end

  example 'retrieve an option' do
    example_class.set(:number, 10)

    example_class.new.option(:number).should == 10
  end

  example 'retrieve an option with a default value' do
    example_class.new.option(:number, 20).should == 20
  end

  example 'evaluate an option value upon retrieval' do
    example_class.set(:dynamic, proc { Struct.new(:example) })

    instance = example_class.new

    instance.option(:dynamic).should_not == instance.option(:dynamic)
  end

  example 'raise for a required but unset option' do
    instance = example_class.new
    block    = lambda { instance.require_option!(:another_number) }

    block.should raise_error(ArgumentError)
  end

  example 'do not raise for a required option with a value' do
    example_class.set(:another_number, 20)

    instance = example_class.new

    instance.require_option!(:another_number)
    instance.option(:another_number).should == 20
  end
end
