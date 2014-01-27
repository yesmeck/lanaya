require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'

module Lanaya
  class Web < Sinatra::Base
    register Sinatra::Reloader

    dir = File.dirname(File.expand_path(__FILE__))

    set :root,  "#{dir}/web"

    get '/' do
      erb :index
    end
  end
end
