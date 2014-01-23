require 'json'
require 'sinatra/base'

module Pismo
  module Server
    class App < Sinatra::Base
      def self.get_or_post(url,&block)
        get(url,&block)
        post(url,&block)
      end

      get_or_post '/' do
        content_type 'application/json'
        doc = Pismo::Document.new(params[:q])
        {
          title: doc.title
          image: doc.image
        }.to_json
      end
    end
  end
end
