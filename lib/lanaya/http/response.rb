module Lanaya
  module Http
    class Resonse
      attr_reader :staus_code, :headers, :http_version

      def initialize(http_parser, body)
        @http_parser = http_parser
        @body = body
      end

      def status_code
        @status ||= @http_parser.status_code
      end

      def headers
        @headers ||= @http_parser.headers
      end

      def http_version
        @http_version ||= 'HTTP/' << @http_parser.version.join('.')
      end
    end
  end
end
