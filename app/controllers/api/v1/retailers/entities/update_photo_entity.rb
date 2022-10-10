module API
  module V1
    module Retailers
      module Entities
        class UpdatePhotoEntity < API::BaseEntity
          root 'retailers', 'retailer'
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :photo_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
        
          private
          def photo_url
            object.photo.url(:medium)
          end
        end                
      end
    end
  end
end