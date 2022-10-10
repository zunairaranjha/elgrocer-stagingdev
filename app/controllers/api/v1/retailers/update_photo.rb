module API
  module V1
    module Retailers
      class UpdatePhoto < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc  "Update photo of the shop. Requires authentication.", entity: API::V1::Retailers::Entities::UpdatePhotoEntity
          params do
            # requires :retailer_id, type: Integer, desc: 'Retailer ID'
            requires :photo, type: Rack::Multipart::UploadedFile, desc: "Photo shop"
          end
          post '/update_photo' do
            retailer = current_retailer
            if params[:photo]
              retailer.photo = ActionDispatch::Http::UploadedFile.new(params[:photo])
              retailer.save
              present retailer, with: API::V1::Retailers::Entities::UpdatePhotoEntity
            else
              error!({error_code: 403, error_message: "Empty photo"},403)
            end
          end
        end
      end      
    end
  end
end