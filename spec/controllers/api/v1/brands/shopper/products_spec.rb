describe API::V1::Brands::ProductsForShopper, type: :request do
  let!(:location) { create(:location) }
  let!(:location2) { create(:location) }
  let!(:location3) { create(:location) }
  let!(:location4) { create(:location) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer2) { create(:retailer) }
  let!(:retailer3) { create(:retailer, is_active: false) }

  let!(:brand) { create(:brand) }

  let!(:brand2) { create(:brand) }

  let!(:product) { create(:product, brand_id: brand.id) }

  let!(:product2) { create(:product, brand_id: brand.id) }

  let!(:product3) { create(:product, brand_id: brand2.id) }

  let!(:product4) { create(:product, brand_id: brand2.id) }

  before do
    create(:shop, retailer: retailer, product: product)
    create(:shop, retailer: retailer, product: product2)
    create(:shop, retailer: retailer, product: product4)
    create(:shop, retailer: retailer2, product: product3)
    create(:shop, retailer: retailer3, product: product3)

    FactoryBot.create(:retailer_opening_hour, retailer_id: retailer.id, open: (Time.now - 3.hour).seconds_since_midnight, close: (Time.now - 2.hour).seconds_since_midnight)
    FactoryBot.create(:retailer_opening_hour, retailer_id: retailer2.id)
    FactoryBot.create(:retailer_opening_hour, retailer_id: retailer3.id)

    FactoryBot.create(:retailer_has_location, location_id: location.id, retailer_id: retailer.id)
    FactoryBot.create(:retailer_has_location, location_id: location2.id, retailer_id: retailer2.id)
    FactoryBot.create(:retailer_has_location, location_id: location3.id, retailer_id: retailer3.id)
  end

  describe 'GET shopper/products' do
    describe 'all Products in base' do
      subject(:request_response) {
        get '/api/v1/brands/shopper/products', params: { page: 1, brand_id: brand2.id }, headers: { "From-Spec" => true }
        JSON.parse(response.body)
      }

      describe 'returned json' do
        it 'contains data of products with all requested attributes' do
          expect(subject['status']).to eq 'success'
          expect(subject['messages']).to be_nil
          expect(subject['data']).to be_a Hash
          expect(subject['data']['products'].size).to eq 2
        end
      end
    end

    describe 'all Products in location' do
      subject(:request_response) {
        get '/api/v1/brands/shopper/products', params: { page: 1, brand_id: brand2.id, location_id: location2.id }, headers: { "From-Spec" => true }
        JSON.parse(response.body)
      }

      describe 'returned json' do
        it 'contains all products in location' do
          expect(subject['status']).to eq 'success'
          expect(subject['messages']).to be_nil
          expect(subject['data']).to be_a Hash
          expect(subject['data']['products'].size).to eq 1
        end
      end
    end

    describe 'no Product when all shops in my location are close' do
      subject(:request_response) {
        get '/api/v1/brands/shopper/products', params: { page: 1, brand_id: brand.id, location_id: location.id }, headers: { "From-Spec" => true }
        JSON.parse(response.body)
      }

      describe 'returned json' do
        it 'contains 0 products when shop is close' do
          expect(subject['status']).to eq 'success'
          expect(subject['messages']).to be_nil
          expect(subject['data']).to be_a Hash
          expect(subject['data']['products'].size).to eq 0
        end
      end
    end

    describe 'no Product when all shops in my location are inactive' do
      subject(:request_response) {
        get '/api/v1/brands/shopper/products', params: { page: 1, brand_id: brand2.id, location_id: location3.id }, headers: { "From-Spec" => true }
        JSON.parse(response.body)
      }

      describe 'returned json' do
        it 'contains 0 products when shop isnt active' do
          expect(subject['status']).to eq 'success'
          expect(subject['messages']).to be_nil
          expect(subject['data']).to be_a Hash
          expect(subject['data']['products'].size).to eq 0
        end
      end
    end

    describe 'all Product in location without retailers' do
      subject(:request_response) {
        get '/api/v1/brands/shopper/products', params: { page: 1, brand_id: brand.id, location_id: location4.id }, headers: { "From-Spec" => true }
        JSON.parse(response.body)
      }

      describe 'returned json' do
        it 'contains 0 products when shop isnt active' do
          expect(subject['status']).to eq 'success'
          expect(subject['messages']).to be_nil
          expect(subject['data']).to be_a Hash
          expect(subject['data']['products'].size).to eq 2
        end
      end
    end
  end
end
