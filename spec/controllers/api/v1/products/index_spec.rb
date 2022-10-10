describe API::V1::Products::Index, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end
  let!(:product) do
    FactoryBot.create(:product)
  end
  let!(:product_in_shop) do
    FactoryBot.create(:product)
  end

  let(:params_in_shop) {
    {
      only_mine: true,
      offset: 0,
      limit: 2
    }
  }
  let(:params_all) {
    {
      only_mine: false,
      offset: 0,
      limit: 2
    }
  }
  before :each do
    @parent = FactoryBot.create(:category)
    @child = FactoryBot.create(:category, { :parent_id => @parent.id, :name => 'Cereal' })
    product.subcategories.push(@child)
    Shop.create({ retailer: retailer, product: product_in_shop })
  end

  describe 'GET /products all Products in base' do
    subject(:request_response) {
      get '/api/v1/products/', params: params_all.merge({ retailer_id: retailer.id }), headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned products' do
      subject(:responsed_products) { JSON.parse(request_response.body)['data']['products'] }
      its(:size) { is_expected.to eq 2 }
    end
  end

  describe 'GET /products only products in my shop' do
    subject(:request_response) {
      get '/api/v1/products/', params: params_in_shop.merge({ retailer_id: retailer.id }), headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned products' do
      subject(:responsed_products) { JSON.parse(request_response.body)['data']['products'] }
      its(:size) { is_expected.to eq 1 }
    end
  end
end
