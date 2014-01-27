require 'em-proxy'
require 'http/parser'
require 'uuid'
require 'thin'
require 'lanaya/http/request'
require 'lanaya/http/response'
require 'lanaya/http/interaction'
require 'lanaya/http/interaction_list'

module Lanaya
  class Proxy < EventMachine::ProxyServer::Connection
    def initialize(*args)
      super
      @buffer = ''
      prepare_http_parser
      bind_on_data
      bind_on_response
      bind_on_finish
    end

    def bind_on_data
      on_data do |data|
        current_interaction.requested_at = Time.now
        @buffer << data
        @http_parser << data
        data
      end
    end

    def bind_on_response
      on_response do |backend, resp|
        response_parser = ::Http::Parser.new
        body = ''
        response_parser.on_body = proc { |chunck| body << chunck  }
        response_parser << resp
        current_interaction.response = Http::Resonse.new(response_parser, body)
        resp
      end
    end

    def bind_on_finish
      on_finish do
        Http::InteractionList.add_interaction current_interaction
        # reset the current interaction
        @current_interaction = nil
      end
    end

    def current_interaction
      @current_interaction ||= Http::Interaction.new
    end

    def prepare_http_parser
      @http_parser = ::Http::Parser.new
      @http_parser.on_headers_complete = proc do
        session = UUID.generate

        current_interaction.request = Http::Request.new(@http_parser)
        puts "New session: #{session} (#{@http_parser.headers.inspect})"

        host, port = @http_parser.headers['Host'].split(':')
        server session, :host => host, :port => (port || 80) #, :bind_host => conn.sock[0] - # for bind ip

        relay_to_servers @buffer

        @buffer.clear
      end
    end
  end
end

