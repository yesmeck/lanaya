module Lanaya
  class Request
    attr_reader :method, :uri, :headers

    def initialize(http_parser)
      @http_paser = http_parser
    end

    def method
      @method ||= @http_paser.http_method
    end

    def uri
      @uri ||= @http_paser.request_url.split(':').last
    end

    def headers
      @uri ||= @http_paser.headers
    end
  end
end
