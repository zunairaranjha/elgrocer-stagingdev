require 'rails_helper'

describe API::V1::ShopperRecipes::SaveRecipe, type: :request do
  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end
  let!(:recipe) do
    FactoryBot.create(:recipe)
  end

  describe 'Post / shopper_recipes' do
    subject(:request_response) {
      post '/api/v1/shopper_recipes/save', params: { recipe_id: recipe.id, is_saved: true }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }

    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      subject(:returned_data) { JSON.parse(request_response.body) }

      it 'contains data of shopper saved recipe request response' do
        res = returned_data
        expect(res['status']).to eq "success"
      end

    end

  end
end