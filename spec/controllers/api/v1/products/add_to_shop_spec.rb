describe API::V1::Products::AddToShop, type: :request do

  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:product) do
    FactoryBot.create(:product)
  end

  describe "POST /products/:id/add_to_shop add product to retailer's shop" do

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res['data']['product']).to be_a Hash
        expect(res['data']['product']['price']).to be_a Hash
        expect(res['data']['product']['price']['price_cents']).to eq 66
        expect(res['data']['product']['price']['price_dollars']).to eq 6
      end
    end

    subject(:request_response) do
      post '/api/v1/products/' + product.id.to_s + '/add_to_shop', params: { price_cents: 66, price_dollars: 6 }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    end
    its(:status) { is_expected.to eq 201 }
  end
end
