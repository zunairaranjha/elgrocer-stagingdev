module API
  module V1
    module AddressTags
      class Index < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :address_tags do
          desc 'To get the list of address tags'
      
          get do
            result = AddressTag.all.order(:priority)
            present result, with: API::V1::AddressTags::Entities::IndexEntity
          end
        end      
      end
    end
  end
end