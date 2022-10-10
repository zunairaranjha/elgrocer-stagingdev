module API
  module V1
    module ShopperRecipes
      class SaveRecipe < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shopper_recipes do
          desc "Save Recipes!"

          params do
            requires :recipe_id, type: Integer, desc: 'Recipe id', documentation: { example: 3 }
            requires :is_saved, type: Boolean, desc: 'Save or delete', documentation: { example: 3 }
          end

          post '/save' do

            if params[:is_saved]
              ShopperRecipe.create(shopper_id: current_shopper.id, recipe_id: params[:recipe_id],
                                   date_time_offset: request.headers['Datetimeoffset'])
            else
              ShopperRecipe.find_by(shopper_id: current_shopper.id, recipe_id: params[:recipe_id]).destroy!
            end
            { message: 'ok' }
          end
        end
      end
    end
  end
end