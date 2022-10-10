describe API::V1::Categories::CategoryShopperBrands, type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:category) { create(:category, name: "New category") }
  let!(:category_child) { create(:category, name: "New category child", parent_id: category.id) }
  let!(:brand) { create(:brand, name: 'Looly') }
  let!(:product) { create(:product, brand_id: brand.id) }
  let!(:product_category) {
    create(:product_category, category_id: category_child.id, product_id: product.id)
  }
  let!(:category1) { create(:category, name: "Old category") }
  let!(:category_child1) {
    create(:category, name: "Old category child", parent_id: category1.id)
  }
  let!(:brand1) { create(:brand, name: 'Brocolly') }

  let!(:product1) { create(:product, brand_id: brand1.id) }
  let!(:product_category1) {
    create(:product_category, category_id: category_child1.id, product_id: product1.id)
  }
  let!(:shop1) {
    create(:shop, product_id: product1.id, retailer_id: retailer.id)
  }

  let(:token) { { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true } }
  let(:params) { { retailer_id: retailer.id, category_id: category_child1.id } }

  describe 'GET /categories/shopper/brands' do
    subject(:request_response) {
      get '/api/v1/categories/shopper/brands', params: params, headers: token
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
end
