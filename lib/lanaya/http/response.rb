module Lanaya
  module Http
    class Resonse
      attr_reader :status_code, :headers, :http_version

      def initialize(http_parser, body)
        @status_code = http_parser.status_code
        @headers = http_parser.headers
        @http_version = 'HTTP/' << http_parser.http_version.join('.')
        @body = body
      end

      def to_hash
        {
          status_code: status_code,
          http_version: http_version,
          headers: headers
        }
      end
    end
  end
end
