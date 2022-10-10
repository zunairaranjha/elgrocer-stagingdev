describe API::V1::Categories::Categories, type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer2) { create(:retailer) }

  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }

  let!(:category) { create(:category, name: "New category") }
  let!(:category1) { create(:category, name: "New empty category") }
  let!(:category2) { create(:category, name: "New 22empty category") }

  let!(:subcategory1) { create(:category, name: "New subcategory", parent_id: category.id) }
  let!(:subcategory2) { create(:category, name: "Second new subcategory", parent_id: category1.id) }
  let!(:subcategory3) { create(:category, name: "Third new subcategory", parent_id: category2.id) }
  let!(:subcategory4) { create(:category, name: "Third new subcategory", parent_id: category2.id) }

  let!(:brand1) { create(:brand) }
  let!(:product1) { create(:product, brand_id: brand1.id) }
  let!(:product_subcategory1) { create(:product_category, category_id: subcategory1.id, product_id: product1.id) }

  let!(:brand2) { create(:brand) }
  let!(:product2) { create(:product, brand_id: brand2.id) }
  let!(:product_subcategory2) { create(:product_category, category_id: subcategory2.id, product_id: product2.id) }

  let!(:brand3) { create(:brand) }
  let!(:product3) { create(:product, brand_id: brand3.id) }
  let!(:product_subcategory3) { create(:product_category, category_id: subcategory3.id, product_id: product3.id) }

  let!(:product4) { create(:product, brand_id: brand3.id) }
  let!(:product_subcategory4) { create(:product_category, category_id: subcategory4.id, product_id: product4.id) }

  let!(:shop1) { create(:shop, product_id: product1.id, retailer_id: retailer.id) }
  let!(:shop2) { create(:shop, product_id: product2.id, retailer_id: retailer.id) }
  let!(:shop3) { create(:shop, product_id: product3.id, retailer_id: retailer2.id) }
  let!(:shop3) { create(:shop, product_id: product4.id, retailer_id: retailer2.id) }

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 2, offset: 0 }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['categories'].size).to eq 2
        expect(res_data['next']).to eq true
      end
    end
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 3, offset: 0 }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['categories'].size).to eq 2
        expect(res_data['next']).to eq false
      end
    end
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 2, offset: 0, parent_id: category.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['categories'].size).to eq 1
        expect(res_data['next']).to eq false
      end
    end
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 2, offset: 0, retailer_id: retailer.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
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
        expect(res_data['categories'].size).to eq 2
        expect(res_data['next']).to eq true # There is a bug here we should address
      end
    end
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 2, offset: 0, retailer_id: retailer.id, parent_id: category.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_data) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_data
        res_data = res['data']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"

        expect(res['data']).to be_a Hash
        expect(res_data['categories'].size).to eq 1
        expect(res_data['next']).to eq false
      end
    end
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories/tree', params: { limit: 2, offset: 0, retailer_id: retailer.id, parent_id: category.id }, headers: { "Authentication-Token" => 'bad_abc23124124', "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 401 }
  end
end
