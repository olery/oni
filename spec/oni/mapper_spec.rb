require 'spec_helper'

describe Oni::Mapper do
  let :example_mapper do
    Class.new(Oni::Mapper)
  end

  example 'set an option of the class' do
    example_mapper.set(:number, 10)

    example_mapper.new.option(:number).should == 10
  end

  example 'return the raw input' do
    input = {:number => 10}

    example_mapper.new.map_input(input).should == input
  end

  example 'return the raw output' do
    output = {:number => 10}

    example_mapper.new.map_output(output).should == output
  end
end
