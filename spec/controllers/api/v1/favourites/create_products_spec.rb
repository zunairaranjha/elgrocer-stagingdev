describe API::V1::Favourites::CreateProducts, type: :request do
  let!(:product) do
    FactoryBot.create(:product)
  end

  let!(:favourite_product) do
    FactoryBot.create(:product)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:shopper_favourite_product) do
    FactoryBot.create(:shopper_favourite_product, {
      shopper_id: shopper.id,
      product_id: favourite_product.id
    })
  end

  describe 'POST /favourite/products' do
    subject(:request_response) {
      post '/api/v1/favourites/products', params: { product_id: product.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }
    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res_data['product']['name']).to eq product.name
      end
    end
  end

  describe 'POST /favourite/products when it should fail!' do
    subject(:request_response) {
      post '/api/v1/favourites/products', params: { product_id: favourite_product.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 422 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        expect(res['messages']).not_to be_nil
        expect(res['status']).not_to eq "success"
        expect(res['data']).not_to be_a Hash
      end
    end
  end

end
