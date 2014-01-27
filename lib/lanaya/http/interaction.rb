module Lanaya
  module Http
    class Interaction < Struct.new(:session_id, :request, :response, :requested_at)
      def to_hash
        {
          session_id: session_id,
          request: request.to_hash,
          response: response.to_hash,
          requested_at: requested_at
        }
      end

      def to_json(*args)
        JSON.generate to_hash
      end
    end
  end
end
