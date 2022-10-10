module API
    module V1
        module CreditCards
            class Root < Grape::API
                version 'v1', using: :path, vendor: 'api'
                format :json
            
                rescue_from :all, backtrace: true
            
                mount API::V1::CreditCards::Index
                mount API::V1::CreditCards::Create
                mount API::V1::CreditCards::Delete            
            end
        end
    end
end