# README

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

* A concurrency model (currently a thread pool)
* Clear separation of logic into 3 distinctive parts
* A common structure for your daemon projects

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

The daemon layer is tasked with receiving a message from an arbitrary location
and scheduling this in the internal job queue (= a thread pool). Upon
completion a custom (optional) action would be triggered to process the output.

The daemon layer can be seen as the controller of an Oni application.

### The Worker

The worker would perform the actual work and return some kind of output to the
daemon. Oni assumes that workers behave reasonably well, currently there's no
mechanism in place to deal with memory leaks and the likes. Oni also assumes
that developers are somewhat capable of dealing with asynchronous code since
all work is performed asynchronously outside of the daemon layer.

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

## Requirements

* Ruby 1.9.3 or newer, preferably an implementation without a GIL such as
  Rubinius or Jruby.
* Basic understanding of threading/concurrent programming

## Installation & Basic Usage

Install the Gem:

    gem install oni

Basic usage of Oni is as following:


```ruby
require 'oni'

class MyWorker < Oni::Worker
  def process(number)
    return number * 2
  end
end

class MyMapper < Oni::Mapper
  def map_input(input)
    return input[:number]
  end

  def map_output(output)
    return {:number => output, :completed => Time.now}
  end
end

class MyDaemon < Oni::Daemon
  set :mapper, MyMapper
  set :worker, MyWorker

  # Here you'd receive your message, e.g. from a queue. We'll use static
  # data as an example.
  def receive
    yield({:number => 10})
  end

  # This would get executed upon completion of a job.
  def complete(result)
    puts result
  end
end
```

[olery]: http://www.olery.com/
[daemon-kit]: https://github.com/kennethkalmer/daemon-kit
