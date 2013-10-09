# README

Oni is a Ruby framework for building concurrent job processing applications,
typically in the form of a daemon. Oni makes it easy to process jobs
concurrently without forcing developers into callback hell as well as providing
other common features such as easy logging using Logstash/Kibana and a clear
separation of logic.

At [Olery][olery] we have quite a few daemon applications (15 or so at the time
of writing, all built using [daemon-kit][daemon-kit]), each serving a different
purpose and most of them having a different code structure.

Oni was made to ensure a consistent structure would exist in every daemon as
well as making it extremely easy to introduce concurrency on a high level and
hook up new features such as benchmarking without having to modify large parts
of individual daemons.

Although Oni was designed to be used as a daemon building framework (and the
namespaces are geared towards this) there's nothing stopping you from running
Oni related code in, for example, a Rails application.

## Requirements

* Ruby 1.9.3 or newer, preferably an implementation without a GIL such as
  Rubinius or Jruby.
* Basic understanding of threading/concurrent programming

## Installation & Basic Usage

Install the Gem:

    gem install oni

Basic usage of Oni is as following:

    require 'oni'

    class MyWorker < Oni::Worker
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def run
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
      def request
        yield {:number => 10}
      end

      # This would get executed upon completion of a job.
      def complete(result)
        some_other_queue.enqueue(result)
      end
    end

## Design

To understand the design of Oni we'll first look at the typical work flow of a
daemon:

1. A job gets put in a queue (Amazon SQS).
2. Daemon polls queue, takes message.
3. Optional message format validation (this was rarely enforced since we had
   control over the input and assumed it to be correct).
4. Work gets offloaded to some extra class, in older designs it would happen in
   the daemon layer directly.
5. Optionally the input data would be modified and re-queued into a separate
   queue. For example, we often pass along data through multiple queues from
   the start until the very end (e.g. batch IDs).

One of the problems we had was that it wasn't always trivial to introduce some
kind of concurrency mechanism, be it using threads or multiple processes.
Another problem was that it wasn't always really clear what part of the code
was tasked with validation, what would actually execute the work, etc.

Of course one can refactor this on a per project basis but then chances are
you'll still end up with (slightly) different structures.

Oni aims to solve these problems by breaking your application up into 3
separate blocks:

* A daemon layer tasked with receiving and scheduling work.
* A worker that actually performs a task (asynchronously)
* A "mapper" tasked with transforming (and validating) input/output for/from
  the worker. It sits between the daemon and the worker.

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

[olery]: http://www.olery.com/
[daemon-kit]: https://github.com/kennethkalmer/daemon-kit
