module API
    module V1
        module ShopperAddresses
            class Root < Grape::API
                version 'v1', using: :path, vendor: 'api'
                format :json
            
                rescue_from :all, backtrace: true
            
                mount API::V1::ShopperAddresses::Index
                mount API::V1::ShopperAddresses::Create
                mount API::V1::ShopperAddresses::Update
                mount API::V1::ShopperAddresses::Delete
            end
            
        end
    end
end