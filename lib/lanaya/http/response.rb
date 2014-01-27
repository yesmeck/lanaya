module Lanaya
  module Http
    class Response
      attr_reader :status_code, :headers, :http_version

      def initialize(http_parser, body)
        @status_code = http_parser.status_code
        @headers = http_parser.headers
        @http_version = 'HTTP/' << http_parser.http_version.join('.')
        @body = body
      end

      def content_type
        headers['Content-Type'] ? headers['Content-Type'].split(';').first : ''
      end

      def to_hash
        {
          http_version: http_version,
          status_code: status_code,
          content_type: content_type,
          headers: headers
        }
      end
    end
  end
end
