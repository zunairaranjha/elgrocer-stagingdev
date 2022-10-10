module API
  module V1
    module Chefs
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :chefs do
          desc "Allows creating a chef. Requires authentication.", entity: API::V1::Chefs::Entities::ShowEntity
          params do
            requires :name, type: String, desc: "Chef name", documentation: { example: "Mehboob Khan" }
            optional :insta, type: String, desc: "Instagram id", documentation: { example: "@ChefMehoobKhanOfficial" }
            optional :blog, type: String, desc: "Blog Link", documentation: { example: "http://example.com" }
            optional :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of Chef"
          end
          post do
            chef = Chef.new(name: params[:name], insta: params[:insta], blog: params[:blog])
            chef.photo = ActionDispatch::Http::UploadedFile.new(params[:photo]) if params[:photo]
            chef.save!
            # present chef, with: API::V1::Chefs::Entities::ShowEntity
          end
        end
      end      
    end
  end
end
