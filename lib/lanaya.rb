require 'pry'
require 'json'
require 'lanaya/version'
require 'lanaya/events'
require 'lanaya/proxy'
require 'lanaya/web'

module Lanaya
  class << self
    def run
      Thin::Logging.silent = true

      EM.epoll
      EM.run do
        EventMachine::start_server('0.0.0.0', 9889, Lanaya::Proxy, {})

        Thin::Server.start '0.0.0.0', 9888, Web

        trap('TERM') { stop }
        trap('INT') { stop }
      end
    end

    def stop
      puts 'Terminating Lanaya'
      EventMachine.stop
    end
  end
end
