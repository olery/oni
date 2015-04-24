require 'aws-sdk'

module Oni
  module Daemons
    ##
    # The SQS daemon is a basic daemon skeleton that can be used to process
    # jobs from an Amazon SQS queue.
    #
    # Basic usage:
    #
    #     class MyDaemon < Oni::Daemons::SQS
    #       set :queue_name, 'my_queue'
    #     end
    #
    # The following options can be set:
    #
    # * `queue_name` (required): the name of the queue to poll as a String.
    # * `poll_options`: a Hash of options to pass to the `poll` method of the
    #   AWS SQS queue. See the documentation of `AWS::SQS::Queue#poll` for more
    #   information on the available options.
    #
    class SQS < Daemon
      ##
      # Checks if the `queue_name` option is set.
      #
      def after_initialize
        require_option!(:queue_name)
      end

      ##
      # Polls an SQS queue for a message and processes it.
      #
      def receive
        queue.poll(poll_options) do |message|
          yield message
        end
      end

      ##
      # Returns a Hash containing the options to use for the `poll` method of
      # the SQS queue.
      #
      # @return [Hash]
      #
      def poll_options
        return option(:poll_options, {})
      end

      ##
      # Returns the queue to use for the current thread.
      #
      # @return [Aws::SQS::QueuePoller]
      #
      def queue
        return Aws::SQS::QueuePoller.new(queue_url)
      end

      ##
      # @return [String]
      #
      def queue_url
        sqs      = Aws::SQS::Client.new
        response = sqs.get_queue_url(:queue_name => option(:queue_name))

        return response.queue_url
      end
    end # SQS
  end # Daemons
end # Oni
