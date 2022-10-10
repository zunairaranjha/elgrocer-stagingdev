describe API::V1::Brands::Products, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:brand) do
    FactoryBot.create(:brand)
  end

  let!(:brand2) do
    FactoryBot.create(:brand)
  end

  let!(:product) do
    FactoryBot.create(:product, {
      brand_id: brand.id
    }
    )
  end

  let!(:product2) do
    FactoryBot.create(:product, {
      brand_id: brand.id
    })
  end

  let!(:product3) do
    FactoryBot.create(:product, {
      brand_id: brand2.id
    }
    )
  end

  describe 'GET /products/per_brand all Products in base' do
    subject(:request_response) {
      get '/api/v1/brands/products', params: { limit: 4, offset: 0, brand_id: brand.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_data) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_data
        res_data = res['data']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data['products'].size).to eq 2
      end
    end
  end

  describe 'GET /products/per_brand all Products in base' do
    subject(:request_response) {
      get '/api/v1/brands/products', params: { limit: 4, offset: 0, brand_id: brand2.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_data) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_data
        res_data = res['data']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data['products'].size).to eq 1
      end
    end
  end

end
