# frozen_string_literal: true

module API
  module V2
    module Shoppers
      require 'uri'
      require 'net/http'
      
      class DigitsVerify < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :shoppers do
      
          desc "Verify user from twitter digits" #, entity: API::V2::Shoppers::Entities::RegisterEntity
      
          params do
            requires :authHeader, type: String, desc: "Credentials or Authentication Headers"
            requires :apiUrl, type: String, desc: "API url"
          end
      
          post '/digits_verify' do
            # Net::HTTP.get(params[:apiUrl], {'Authorization' => params[:authHeader]})
            # request.initialize_http_header({"Authorization" => params[:authHeader]})
      
            # http = Net::HTTP.new(url.host, url.port)
            # http.use_ssl = true
            # http.open_timeout = 5 # create connection timeout after 5 seconds
            # http.ssl_timeout = 5  # read timeout after 5 seconds
            # resp, data = http.get2(url.path, {'Authorization' => params[:authHeader]})
      
            uri = URI.parse(params[:apiUrl])
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(uri.request_uri, {'Authorization'=>params[:authHeader]})
            response = http.request(request)
            digitRes = ActiveSupport::JSON.decode(response.body)
            already_exists = Shopper.exists?(phone_number: digitRes['phone_number']) ? 1 : 0
            # {digit_data: digitRes, is_phone_exists: already_exists}
            {
              phoneNumber: digitRes['phone_number'],
              userID: digitRes['id_str'],
              is_phone_exists: already_exists,
              error: ''
            }
            # digitRes.push({ is_exists: already_exists })
            # present digitRes
          end
        end
      end      
    end
  end
end