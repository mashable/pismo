require 'json'
require 'open-uri'
require 'sinatra/base'

module Pismo
  module Server
    VINE_API_URL = "https://api.vineapp.com/timelines/posts/s/"
    BRIGHTCOVE_API_URL = "https://api.brightcove.com/services/library?command=find_video_by_id"

    class App < Sinatra::Base
      def self.get_or_post(url,&block)
        get(url,&block)
        post(url,&block)
      end

      def extract_vine_data(url)
        vine_id = url.split('/').pop
        request_url = "#{VINE_API_URL}#{vine_id}"
        data =
          begin
            resp = JSON.parse open(request_url, "User-Agent" => "MashableBot").read
            attrs = resp['data']['records'].first
            attrs['userId'] = attrs['userId'].to_s
            attrs
          rescue
            {}
          end
        data.to_json
      end

      def extract_brightcove_data(query)
        vid = query.split('-')[1]
        params = {
          video_id: vid,
          video_fields: 'name,shortDescription,videoStillURL',
          token: Pismo::Configuration.options[:brightcove_read_token]
        }
        request_url = "#{BRIGHTCOVE_API_URL}&#{params.to_query}"
        data =
          begin
            resp = JSON.parse open(request_url, "User-Agent" => "MashableBot").read
          rescue
            {}
          end
        data.to_json
      end

      get_or_post '/' do
        content_type 'application/json'
        headers 'Cache-Control' => "no-cache",
          'X-Ignore-Cookie' => '0'
        query = params[:q]
        if query.match(/vine\.co/)
          attrs = extract_vine_data query
        elsif query.match(/bcove/)
          attrs = extract_brightcove_data query
        else
          doc = Pismo::Document.new query
          attrs = {
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
        attrs
      end
    end
  end
end
