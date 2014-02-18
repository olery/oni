# Oni

* [Design](#design)
  * [The Daemon](#the-daemon)
  * [The Mapper](#the-mapper)
  * [The Worker](#the-worker)
* [Requirements](#requirements)
* [Installation & Basic Usage](#installation--basic-usage)
* [License](#license)

Oni is a Ruby framework that aims to make it easier to write concurrent daemons
using a common code structure. Oni itself does not actually daemonize your
code, manage PID files, resources, etc. Instead you should use Oni in
combination with other Gems such as [daemon-kit][daemon-kit].

Oni was built to standardize the structure amongst the different daemon-kit
projects used at [Olery][olery]. As time progressed new structures were used
for new daemons and the old ones were often left as is.

Another problem we faced was concurrency. Most daemons were built in a
single threaded, single processed manner without an easy place to hook some
kind of concurrency model in.

Oni takes care of these problems by providing the following:

* A concurrency model in the form of separate worker threads (5 by default).
* Clear separation of logic into 3 distinctive parts.
* A common structure for your daemon projects.

Oni assumes developers are somewhat familiar with threading and the potential
issues that may arise, it also assumes that your code doesn't leak large
amounts of memory over time. Currently there are no plans to include some kind
of internal resource management system in Oni, this may change in the future.

## Design

To understand the design of Oni we'll first look at the typical work flow of a
daemon:

1. A job gets put in a queue (Amazon SQS).
2. Daemon polls queue, takes message.
3. Optional message format validation (this was rarely enforced since we had
   control over the input and assumed it to be correct).
4. Work gets offloaded to some extra class, in older designs of our daemons it
   would happen in the daemon layer directly.
5. Optionally the input data would be modified and re-queued into a separate
   queue. For example, we often pass along data through multiple queues from
   the start until the very end (e.g. batch IDs).

Oni tries to make these kind of workflows by breaking them up into 3 different
layers:

1. A daemon layer tasked with receiving and scheduling work.
2. A "mapper" tasked with transforming (and validating) input/output for/from
   the worker. It sits between the daemon and the worker.
3. A worker that actually performs a task (asynchronously)

Each layer would only do the specific thing it should be doing and would
offload other work to the next step in the process. The 3 parts are described
in detail below.

### The Daemon

The daemon layer spawns a number of threads that will each receive and perform
work separately. Typically these workers are long running tasks that poll some
kind of message queue for jobs to process.

In initial iterations Oni used a main job dispatcher (running in the main
thread) and a separate thread pool for the workers. This proved problematic
with message queue setups as it would result in the main thread pulling in all
available jobs and then internally queing them again given there weren't enough
workers available. This would mean that if the process would crash the messages
were lost. As a result of this each worker is started in it's own separate
thread.

Comparing Oni with other framework structures one could see the daemon layer as
a controller (in MVC frameworks), it merely dispatches work to the mapper and
worker instead of doing everything itself.

### The Mapper

The mapper is tasked with two things:

1. Take the input from the daemon, validate it and transform it into a
   structure that the worker can understand.
2. Take the resulting output, optionally modify it and pass it back to the
   daemon.

The input transformation is put in place to ensure that workers only get data
that they actually need instead of just receiving the raw message (which may
include all kinds of meta data completely useless to a worker). It also ensures
that the input is actually correct before ever passing it to a worker.

A typical thing at Olery is that a job gets scheduled and has to pass through
multiple steps (= daemons) before being completed. Some of these daemons would
add extra meta-data to the message (e.g. batch IDs, timings, etc) but these
aren't strictly required to perform an actual job, thus there's no need to pass
it around several layers deep into your codebase.

In the above case the mapper would take care of validating/scrubbing the input
and adding extra meta-data to the output.

### The Worker

The worker would perform the actual work and return some kind of output to the
daemon. Oni assumes that workers behave reasonably well, currently there's no
mechanism in place to deal with memory leaks and the likes. Oni also assumes
that developers are somewhat capable of dealing with asynchronous code since
all work is performed asynchronously outside of the daemon layer.

## Requirements

* Ruby 1.9.3 or newer, preferably an implementation without a GIL such as
  Rubinius or Jruby.
* Basic understanding of threading/concurrent programming

## Installation & Basic Usage

Install the Gem:

    gem install oni

Basic usage of Oni is as following:

    require 'oni'

    # This example defines 3 classes: MyDaemon, MyMapper and MyWorker.
    # Combined they form the basic structure of an Oni Daemon.

    class MyDaemon < Oni::Daemon
      set :mapper, MyMapper
      set :worker, MyWorker

      # Here you'd receive your message, e.g. from a queue. We'll use static
      # data as an example.
      def receive
        yield({:number => 10})
      end

      # This would get executed upon completion of a job.
      def complete(message, result, timings)
        puts result
      end
    end

    class MyMapper < Oni::Mapper
      # Map the input given by MyDaemon#receive into the right arguments
      # for MyWorker#initialize. 
      #
      # NOTE: the return value should be an Array. 
      # Oni calls #to_a on the output (more specifically we use a splat) so your 
      # return value should be an Array. If you do not return an Array you risk
      # that the object you return will wrongfully be converted into an Array.
      # This is painful when it comes to Hashes, which, after the #to_a call
      # will be converted into arrays of values in stead of your intended hash.
      def map_input(input)
        return [input[:number]]
      end

      def map_output(output)
        return {:number => output, :completed => Time.now}
      end
    end

    class MyWorker < Oni::Worker
      def initialize(number)
        @number = number
      end

      def process
        return @number * 2
      end
    end

## License

The source code of this repository and Oni itself are licensed under the MIT
license unless specified otherwise. A copy of this license can be found in the
file "LICENSE" in the root directory of this repository.

[olery]: http://www.olery.com/
[daemon-kit]: https://github.com/kennethkalmer/daemon-kit
