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
    # The queue name is required, without you won't be able to create an
    # instance of this class.
    #
    class SQS < Daemon
      ##
      # Checks if the `queue_name` option is set.
      #
      def after_initialize
        require_option!(:queue_name)
      end

      ##
      # Polls an SQS queue and gives it back to the daemon.
      #
      def receive
        queue.poll do |message|
          yield message
        end
      end

      ##
      # @return [AWS::SQS::Queue]
      #
      #:nocov:
      def queue
        return @queue ||= AWS::SQS.new.queues.named(option(:queue_name))
      end
      #:nocov:
    end # SQS
  end # Daemons
end # Oni
