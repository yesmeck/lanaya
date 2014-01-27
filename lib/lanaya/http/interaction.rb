module Lanaya
  module Http
    class Interaction < Struct.new(:request, :response, :requested_at)
      def to_json
        JSON.generate(request: request, response: response, requested_at: requested_at)
      end
    end
  end
end
