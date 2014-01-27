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
      @request_buffer = ''
      @response_body = ''
      prepare_request_parser
      prepare_response_parser
      bind_on_data
      bind_on_response
      bind_on_finish
    end

    def bind_on_data
      on_data do |data|
        current_interaction.requested_at = Time.now
        @request_buffer << data
        @request_parser << data
        data
      end
    end

    def bind_on_response
      on_response do |backend, resp|
        @response_parser << resp
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

    def prepare_request_parser
      @request_parser = ::Http::Parser.new
      @request_parser.on_headers_complete = proc do
        session = UUID.generate

        current_interaction.request = Http::Request.new(@request_parser)
        puts "New session: #{session} (#{@request_parser.headers.inspect})"

        host, port = @request_parser.headers['Host'].split(':')
        server session, :host => host, :port => (port || 80) #, :bind_host => conn.sock[0] - # for bind ip

        relay_to_servers @request_buffer

        @request_buffer.clear
      end
    end

    def prepare_response_parser
      @response_parser = ::Http::Parser.new
      @response_parser.on_body = proc { |chunck| @response_body << chunck }
      @response_parser.on_message_complete = proc do
        current_interaction.response = Http::Resonse.new(@response_parser, @response_body)
        @response_body.clear
      end
    end
  end
end

