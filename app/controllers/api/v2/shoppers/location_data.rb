module API
  module V2
    module Shoppers
      class LocationData < Grape::API
        version 'v2', using: :path
        format :json

        resource :shoppers do
          desc "Check client ip and send it to ip registry"

          params do
            optional :ip_address, type: String, desc: 'ip address', documentation: { example: 102.334 }
          end

          get '/locationdata' do
            puts "This is location data api"
            client_ip = params[:ip_address] || headers['X-Forwarded-For'].to_s.split(',').first.to_s
            response = Faraday.get("https://api.ipregistry.co/#{client_ip}?key=rrcq2n5st2zgtty2")
            JSON(response.body)
            end
        end
      end
    end
  end
end