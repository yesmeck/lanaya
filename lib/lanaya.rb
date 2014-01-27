require 'pry'
require "lanaya/proxy"

module Lanaya
  class << self
    def run
      EM.epoll
      EM.run do
        trap('TERM') { stop }
        trap('INT') { stop }

        EventMachine::start_server('0.0.0.0', 9889, Lanaya::Proxy, {})
      end
    end

    def stop
      EventMachine.stop
    end
  end
end
