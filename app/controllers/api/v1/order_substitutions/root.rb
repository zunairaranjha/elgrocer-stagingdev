module API
  module V1
    module OrderSubstitutions
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::OrderSubstitutions::Create
        mount API::V1::OrderSubstitutions::Update
        mount API::V1::OrderSubstitutions::Index
        mount API::V1::OrderSubstitutions::SelectingProducts
      
        # that codeshit, missed number with 'Using geos version', so trying another build :(
        
      end
    end
  end
end