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

    web_dir = File.expand_path('../../../web', __FILE__)

    set :public_folder, File.join([web_dir, 'tmp', 'result'])

    get '/config/*' do |path|
      send_file File.join([web_dir, 'config', path])
    end

    get '/vendor/*' do |path|
      send_file File.join([web_dir, 'vendor', path])
    end

    get '/tests' do |path|
      send_file File.join([settings.public_folder, 'tests', 'index.html'])
    end

    get '/tests/*' do |path|
      send_file File.join([web_dir, 'tests', path])
    end

    get '/' do
      send_file File.join([settings.public_folder, 'index.html'])
    end

    get '/:session_id/response_body' do |session_id|
      Lanaya::Http::InteractionList[session_id].response.body
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
