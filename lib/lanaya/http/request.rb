module Lanaya
  module Http
    class Request
      attr_reader :method, :uri, :headers

      def initialize(http_parser)
        @method = http_parser.http_method
        @uri = URI(http_parser.request_url)
        @headers = http_parser.headers
      end

      def to_hash
        {
          method: method,
          uri: uri,
          headers: headers
        }
      end
    end
  end
end
