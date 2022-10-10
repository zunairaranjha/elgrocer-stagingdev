module API
  module V1
    module RecipeCategories
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :recipe_categories do
          desc "Retuen the RecipeCategories", entity: API::V1::RecipeCategories::Entities::ShowEntity
          params do
            optional :limit, type: Integer, desc: "limit of RecipeCategories", documentation: { example: 10 }
            optional :offset, type: Integer, desc: "Offset of RecipeCategories", documentation: { example: 0 }
            optional :id, desc: "ID of RecipeCategory", documentation: {example: 1}
          end
          get do
            if params[:id]
              result = RecipeCategory.includes(:recipe_subcategories).find(params[:id])
            else
              result = RecipeCategory.includes(:recipe_subcategories).where(parent_id: nil).order(:id).limit(params[:limit]).offset(params[:offset])
            end
            present result, with: API::V1::RecipeCategories::Entities::ShowEntity, web: request.headers['Referer']
          end
        end
      end      
    end
  end
end