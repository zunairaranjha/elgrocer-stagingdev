module API
  module V1
    module ProductSuggestions
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::ProductSuggestions::Create
      
        # that codeshit, missed number with 'Using geos version', so trying another build :(
      
      end      
    end
  end
end