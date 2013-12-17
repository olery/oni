require 'spec_helper'

describe Oni::WrappedError do
  before do
    @original_error = StandardError.new('Hello world')
    @parameters     = {:foo => :bar}
  end

  context 'manually creating instances' do
    example 'set the message' do
      Oni::WrappedError.new('foo').message.should == 'foo'
    end

    example 'set the original error' do
      error = Oni::WrappedError.new('foo', :original_error => @original_error)

      error.original_error.should == @original_error
    end

    example 'set the parameters' do
      error = Oni::WrappedError.new('foo', :parameters => @parameters)

      error.parameters.should == @parameters
    end
  end

  context 'creating instances from other errors' do
    before do
      @error = Oni::WrappedError.from(@original_error, @parameters)
    end

    example 'set the message' do
      @error.message.should == @original_error.message
    end

    example 'set the original error' do
      @error.original_error.should == @original_error
    end

    example 'set the parameters' do
      @error.parameters.should == @parameters
    end
  end
end
