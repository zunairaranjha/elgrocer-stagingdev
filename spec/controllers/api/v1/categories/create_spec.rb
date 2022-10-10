describe API::V1::Categories::Create, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end
  let!(:category) do
    FactoryBot.create(:category, {
      name: "New category"
    }
    )
  end

  describe 'GET /categories' do
    subject(:request_response) {
      post '/api/v1/categories', params: { category_name: "Soups & Oil", subcategory_name: "GoodFood" }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data['name']).to eq "Soups & Oil"
        expect(res_data['children'][0]['name']).to eq "GoodFood"
      end
    end
  end

end
