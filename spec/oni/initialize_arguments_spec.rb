require 'spec_helper'

describe Oni::InitializeArguments do
  let :example_class do
    Class.new do
      attr_reader :a, :b

      include Oni::InitializeArguments
    end
  end

  example 'set of a collection of attributes' do
    instance = example_class.new(:a => 10, :b => 20)

    instance.a.should == 10
    instance.b.should == 20
  end
end
