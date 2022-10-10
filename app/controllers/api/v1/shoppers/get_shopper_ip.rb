module API
  module V1
    module Shoppers
      class GetShopperIp < Grape::API
        use ActionDispatch::RemoteIp
        version 'v1', using: :path
        format :json
      
        resource :shoppers do
      
          desc "Return The Shopper's Ip address"
      
          params do
          end
      
          get '/get_shopper_ip' do
            env['action_dispatch.remote_ip'].to_s
          end
        end
      end
    end
  end
end