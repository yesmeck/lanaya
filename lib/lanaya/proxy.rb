require 'em-proxy'
require 'http/parser'
require 'uuid'
require 'thin'
require 'lanaya/request'
require 'lanaya/response'

module Lanaya
  class Proxy < EventMachine::ProxyServer::Connection
    def initialize(*args)
      super
      @buffer = ''
      prepare_http_parser
      bind_on_data
      bind_on_response
    end

    def bind_on_data
      on_data do |data|
        @buffer << data
        @http_parser << data
        data
      end
    end

    def bind_on_response
      on_response do |backend, resp|
        response_parser = Http::Parser.new
        body = ''
        response_parser.on_body = proc { |chunck| body << chunck  }
        response_parser << resp
        response = Resonse.new(response_parser, body)
        resp
      end
    end

    def prepare_http_parser
      @http_parser = Http::Parser.new
      @http_parser.on_headers_complete = proc do
        session = UUID.generate

        request = Request.new(@http_parser)
        puts "New session: #{session} (#{@http_parser.headers.inspect})"

        host, port = @http_parser.headers['Host'].split(':')
        server session, :host => host, :port => (port || 80) #, :bind_host => conn.sock[0] - # for bind ip

        relay_to_servers @buffer

        @buffer.clear
      end
    end
  end
end

