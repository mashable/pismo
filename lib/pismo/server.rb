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
          description:  doc.description,
          soundcloud:   doc.soundcloud,
          instagram:    doc.instagram,
          twitter:      doc.twitter,
          youtube:      doc.youtube,
          ustream:      doc.ustream,
          sitename:     doc.sitename,
          title:        doc.title,
          image:        doc.image,
          vine:         doc.vine
        }.to_json
      end
    end
  end
end
