require 'spec_helper'

describe Oni::ThreadPool do
  example 'start and stop a pool' do
    size = 2
    pool = Oni::ThreadPool.new(size)

    pool.start
    pool.threads.length.should == size
    pool.stop
  end

  example 'schedule work in the pool' do
    number = 0
    size   = 2
    pool   = Oni::ThreadPool.new(size)

    pool.start

    size.times do
      pool.schedule { number += 1 }
    end

    pool.stop

    number.should == size
  end

  example 'raise for scheduling invalid jobs' do
    pool = Oni::ThreadPool.new(1)

    pool.start

    lambda { pool.schedule }.should raise_error(LocalJumpError)

    pool.stop
  end
end
