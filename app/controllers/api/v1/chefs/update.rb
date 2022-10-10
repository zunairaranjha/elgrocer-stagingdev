module API
  module V1
    module Chefs
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :chefs do
          desc "Allows update a chef. Requires authentication.", entity: API::V1::Chefs::Entities::ShowEntity
          params do
            requires :id, type: Integer, desc: "ID of chef", documentation: {example: 10}
            optional :name, type: String, desc: "Chef name", documentation: { example: "Mehboob Khan" }
            optional :insta, type: String, desc: "Instagram id", documentation: { example: "@ChefMehoobKhanOfficial" }
            optional :blog, type: String, desc: "Blog Link", documentation: { example: "http://example.com" }
            optional :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of Chef"
          end
          put do
            chef = Chef.find(params[:id])
            object = {
              name: params[:name],
              insta: params[:insta],
              blog: params[:blog]
            } 
            chef.photo = ActionDispatch::Http::UploadedFile.new(params[:photo]) if params[:photo]
            chef.update!(object.compact)
            # chef.name = params[:name] if params[:name]
            # chef.insta = params[:insta] if params[:insta]
            # chef.blog = params[:blog] if params[:blog]
            # present chef, with: API::V1::Chefs::Entities::ShowEntity
          end
        end
      end      
    end
  end
end