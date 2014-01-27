require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require 'skinny'

class Sinatra::Request
  include Skinny::Helpers
end

module Lanaya
  class Web < Sinatra::Base
    register Sinatra::Reloader

    dir = File.dirname(File.expand_path(__FILE__))

    set :root,  "#{dir}/web"

    get '/' do
      @records = []
      erb :index
    end

    get '/interactions' do
      if request.websocket?
        request.websocket!(on_start: proc do |websocket|
          subscription = Lanaya::Events::HttpInteractionAdded.subscribe do |interaction|
            websocket.send_message interaction.to_json
          end

          websocket.on_close do |websocket|
            Lanaya::Events::HttpInteractionAdded.unsubscribe subscription
          end
        end)
      else
        Lanaya::Http::InteractionList.to_json
      end
    end
  end
end
