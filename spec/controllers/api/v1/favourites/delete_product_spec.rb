describe API::V1::Favourites::DeleteProduct, type: :request do
  let!(:product) do
    FactoryBot.create(:product)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:shopper_favourite_product) do
    FactoryBot.create(:shopper_favourite_product, {
      shopper_id: shopper.id,
      product_id: product.id
    })
  end

  describe 'DELETE /favourite/products' do
    subject(:request_response) {
      delete '/api/v1/favourites/products', params: { product_id: product.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res_data['message']).not_to be_nil
      end
    end
  end

end
