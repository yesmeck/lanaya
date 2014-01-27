require 'singleton'

module Lanaya
  module Http
    class InteractionList
      attr_reader :interactions

      include Singleton

      def initialize
        @interactions = []
      end

      def add_interaction(interaction)
        @interactions << interaction
        EventMachine.next_tick do
          Lanaya::Events::HttpInteractionAdded.push interaction
        end
      end

      def to_json
        JSON.generate @interactions
      end

      class << self
        def to_json
          instance.to_json
        end

        def method_missing(name, *args)
          instance.send(name, *args)
        end
      end
    end
  end
end
