describe API::V1::Retailers::ShowProducts, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:brand1) do
    FactoryBot.create(:brand)
  end

  let!(:brand2) do
    FactoryBot.create(:brand)
  end

  let!(:brand3) do
    FactoryBot.create(:brand)
  end

  let!(:product1) do
    FactoryBot.create(:product, {
      brand_id: brand1.id
    })
  end

  let!(:product2) do
    FactoryBot.create(:product, {
      brand_id: brand2.id
    })
  end

  let!(:shop1) do
    FactoryBot.create(:shop, {
      product_id: product1.id,
      retailer_id: retailer.id
      # price_dollars: 1,
      # price_cents: 1,
      # price_currency: 'AED'
    })
  end

  let!(:shop2) do
    FactoryBot.create(:shop, {
      product_id: product2.id,
      retailer_id: retailer.id
      # price_dollars: 1,
      # price_cents: 1,
      # price_currency: 'AED'
    })
  end

  describe 'GET /retailers/products' do
    subject(:request_response) {
      get '/api/v1/retailers/products', params: { retailer_id: retailer.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      # puts(JSON.parse(response.body))
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        products_data = res_data['products']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(products_data.size).to eq 2
      end
    end
  end

  describe 'GET /retailers/products' do
    subject(:request_response) {
      get '/api/v1/retailers/products', params: { retailer_id: retailer.id, brand_id: brand1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      # puts(JSON.parse(response.body))
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        products_data = res_data['products']
        first_product = products_data[0]
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(products_data.size).to eq 1
        expect(first_product['retailer_id']).to eq retailer.id
      end
    end
  end

  describe 'GET /retailers/products' do
    subject(:request_response) {
      get '/api/v1/retailers/products', params: { retailer_id: retailer.id, brand_id: brand3.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      # puts(JSON.parse(response.body))
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        products_data = res_data['products']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(products_data.size).to eq 0
      end
    end
  end
end
