describe API::V1::Categories::CategoryBrands, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:category) do
    FactoryBot.create(:category, {
      name: "New category"
    }
    )
  end

  let!(:category_child) do
    FactoryBot.create(:category, {
      name: "New category child",
      parent_id: category.id
    }
    )
  end

  let!(:brand) do
    FactoryBot.create(:brand, {
      name: 'Looly'
    }
    )
  end

  let!(:product) do
    FactoryBot.create(:product, {
      brand_id: brand.id
    }
    )
  end

  let!(:product_category) do
    FactoryBot.create(:product_category, {
      category_id: category_child.id,
      product_id: product.id
    }
    )
  end

  let!(:category1) do
    FactoryBot.create(:category, {
      name: "Old category"
    }
    )
  end
  let!(:category_child1) do
    FactoryBot.create(:category, {
      name: "Old category child",
      parent_id: category1.id
    }
    )
  end

  let!(:brand1) do
    FactoryBot.create(:brand, {
      name: 'Brocolly'
    }
    )
  end

  let!(:product1) do
    FactoryBot.create(:product, {
      brand_id: brand1.id
    }
    )
  end

  let!(:product_category1) do
    FactoryBot.create(:product_category, {
      category_id: category_child1.id,
      product_id: product1.id
    }
    )
  end

  let!(:shop1) do
    FactoryBot.create(:shop, {
      product_id: product1.id,
      retailer_id: retailer.id
    }
    )
  end

  describe 'GET /categories/brands' do
    subject(:request_response) {
      get '/api/v1/categories/brands', params: { category_id: category_child.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['brands'].size).to eq 1
      end
    end
  end

  describe 'GET /categories/brands' do
    subject(:request_response) {
      get '/api/v1/categories/brands', params: { category_id: category_child1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['brands'].size).to eq 1
      end
    end
  end

  describe 'GET /categories/brands' do
    subject(:request_response) {
      get '/api/v1/categories/brands', params: { category_id: category_child.id }, headers: { "Authentication-Token" => retailer.authentication_token + 'blah', "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 401 }
  end

end
