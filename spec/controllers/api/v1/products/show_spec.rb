describe API::V1::Products::Show, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end
  let!(:product) do
    FactoryBot.create(:product)
  end
  before :each do
    @parent = FactoryBot.create(:category)
    @child = FactoryBot.create(:category, { :parent_id => @parent.id, :name => 'Cereal' })
    product.subcategories.push(@child)
  end

  describe 'GET /products/:barcode LOCAL' do
    subject(:request_response) {
      get '/api/v1/products/' + product.barcode, params: {}, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res['data']['product']).to be_a Hash
        expect(res['data']['product']['id']).to eq product.id
        expect(res['data']['product']['barcode']).to eq product.barcode
        expect(res['data']['product']['shelf_life']).to eq product.shelf_life
      end
    end
  end

  describe 'GET /products/:barcode NON-LOCAL with image' do
    subject(:request_response) {
      get '/api/v1/products/013562610020', params: {}, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res['data']['product']).to be_a Hash
      end
    end
  end

  describe 'GET /products/:barcode NON-LOCAL without image' do
    subject(:request_response) {
      get '/api/v1/products/039400017233', params: {}, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res['data']['product']['is_local']).to eq false
      end
    end
  end

  describe 'GET non-existent product' do
    subject(:request_response) {
      get '/api/v1/products/66667777', params: {}, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res['data']['product']['is_local']).to eq false
        expect(res['data']['product']['barcode']).to eq "66667777"
      end
    end
  end
end
