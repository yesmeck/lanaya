require 'eventmachine'

module Lanaya
  module Events
    HttpInteractionAdded = EventMachine::Channel.new
  end
end
