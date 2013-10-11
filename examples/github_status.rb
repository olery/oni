require_relative '../lib/oni'
require 'net/https'
require 'json'

module GithubStatus
  class Mapper < Oni::Mapper
    def map_input(input)
      return input['url']
    end

    def map_output(output)
      return output['status']
    end
  end

  class Worker < Oni::Worker
    def process(url)
      uri_object   = URI.parse(url)
      http         = Net::HTTP.new(uri_object.host, uri_object.port)
      http.use_ssl = true
      request      = Net::HTTP::Get.new(uri_object.request_uri)
      response     = http.request(request)

      return JSON(response.body)
    end
  end

  class Daemon < Oni::Daemon
    # Check GitHub every 10 minutes.
    set :interval, 600

    # The URL to check.
    set :status_url, 'https://status.github.com/api/status.json'

    set :mapper, Mapper
    set :worker, Worker

    def receive
      loop do
        # This is to mimic some kind of job coming from a queue.
        yield({'url' => option(:status_url)})

        sleep(option(:interval))
      end
    end

    def complete(status)
      puts "GitHub status: #{status}"
    end
  end # Daemon
end # GithubStatus

daemon = GithubStatus::Daemon.new

daemon.start