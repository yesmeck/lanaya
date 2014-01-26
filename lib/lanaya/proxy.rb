require 'em-proxy'
require 'http/parser'
require 'uuid'
require 'pry'
require 'lanaya/request'
require 'lanaya/response'

module Lanaya
  class Proxy < Proxy
    class << self
      def run!(host: '0.0.0.0', port: 9889)
        start(:host => host, :port => port) do |conn|

          @http_paser = Http::Parser.new
          @http_paser.on_headers_complete = proc do
            session = UUID.generate

            request = Request.new(@http_paser)
            puts "New session: #{session} (#{@http_paser.headers.inspect})"

            host, port = @http_paser.headers['Host'].split(':')
            conn.server session, :host => host, :port => (port || 80) #, :bind_host => conn.sock[0] - # for bind ip

            conn.relay_to_servers @buffer

            @buffer.clear
          end

          @buffer = ''

          conn.on_data do |data|
            @buffer << data
            @http_paser << data

            data
          end

          conn.on_response do |backend, resp|
            response_parser = Http::Parser.new
            body = ''
            response_parser.on_body = proc { |chunck| body << chunck  }
            response_parser << resp
            response = Resonse.new(response_parser, body)
            resp
          end
        end
      end
    end
  end
end
