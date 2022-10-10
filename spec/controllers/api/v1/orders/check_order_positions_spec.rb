describe API::V1::Orders::CheckOrderPositions, type: :request do
  let!(:retailer) { create(:retailer, :with_delivery_zone) }

  let!(:opening_hour1) do
    create(:retailer_opening_hour, { retailer_id: retailer.id })
  end

  let!(:shopper) do
    create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0'))
  end
  let(:token) { {"Authentication-Token" => shopper.authentication_token , "From-Spec" => true } }
  let(:longitude) { '55.2842' }
  let(:latitude)  { '25.2386' }

  let!(:product1) { create(:product, { name: 'Bread'  }) }
  let!(:product2) { create(:product, { name: 'Butter' }) }
  let!(:product3) { create(:product, { name: 'Cheese' }) }
  let!(:product4) { create(:product, { name: 'Ham'    }) }

  let!(:shop1) { create(:shop, { retailer_id: retailer.id, product_id: product1.id }) }
  let!(:shop2) { create(:shop, { retailer_id: retailer.id, product_id: product2.id }) }
  let!(:shop3) { create(:shop, { retailer_id: retailer.id, product_id: product3.id }) }

  let!(:check_order_positions_params) do
    { latitude: latitude, longitude: longitude, products: [product1.id, product2.id] }
  end
  let!(:check_order_positions_params2) do
    { latitude: latitude, longitude: longitude, products: [product1.id, product2.id, product4.id] }
  end
  let!(:check_order_positions_params3) do
    { latitude: latitude, longitude: longitude, products: [product1.id, product1.id, product1.id] }
  end

  let!(:expected_retailers1) do
    [
      {
        "retailer": {
          "id": retailer.id,
          "company_name": retailer.company_name,
          "company_address": retailer.company_address,
          "is_favourite": false,
          "average_rating": 0,
          "photo_url": retailer.photo_url,
          "available_payment_types": []
        },
        "products": []
      }
    ]
  end

  let!(:expected_retailers2) do
    [
      {
        "retailer": {
          "id": retailer.id,
          "company_name": retailer.company_name,
          "company_address": retailer.company_address,
          "is_favourite": false,
          "average_rating": 0,
          "photo_url": retailer.photo_url,
          "available_payment_types": []
        },
        "products": [product4.id]
      }
    ]
  end


  describe 'POST /orders/check' do
    context "when params are correct" do
      subject(:request_response) {
        post '/api/v1/orders/check', params: check_order_positions_params, headers: token
        response
      }

      it { expect(subject.status).to eq 201 }


      describe 'returned json' do
        subject(:returned_orders) {JSON.parse(request_response.body)}

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          res_data = res['data']
          retailers = res_data['retailers']
          order = retailers[0]
          orders_unavailable_products = order['unavailable_products']
          orders_available_products = order['available_products']
          first_available_product = orders_available_products[0]
          orders_retailer = order['retailer']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).to be_a Hash

          expect(retailers.size).to eq 1

          expect(orders_retailer['id']).to eq expected_retailers1[0][:retailer][:id]
          expect(orders_retailer['company_name']).to eq expected_retailers1[0][:retailer][:company_name]
          expect(orders_retailer['company_address']).to eq expected_retailers1[0][:retailer][:company_address]

          expect(orders_unavailable_products.size).to eq 0

          expect(first_available_product['price']).not_to be_nil
        end
      end
    end
  end

  describe 'POST /orders/check' do
    context "when params are correct but one product is not in shop" do
      subject(:request_response) {
          post '/api/v1/orders/check', params: check_order_positions_params2, headers: token
          response
      }

      it { expect(subject.status).to eq 201}

      describe 'returned json' do
        subject(:returned_orders) {JSON.parse(request_response.body)}

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          res_data = res['data']
          retailers = res_data['retailers']
          order = retailers[0]
          orders_unavailable_products = order['unavailable_products']
          orders_available_products = order['available_products']
          orders_retailer = order['retailer']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).to be_a Hash

          expect(retailers.size).to eq 1

          expect(orders_retailer['id']).to eq expected_retailers2[0][:retailer][:id]
          expect(orders_retailer['company_name']).to eq expected_retailers2[0][:retailer][:company_name]
          expect(orders_retailer['company_address']).to eq expected_retailers2[0][:retailer][:company_address]

          expect(orders_unavailable_products.size).to eq 1
          expect(orders_available_products.size).to eq 2
        end
      end
    end

    context "not covered" do
      let(:longitude) { '54.2842' }
      let(:latitude)  { '24.2386' }

      subject(:request_response) {
        post '/api/v1/orders/check', params: check_order_positions_params, headers: token
        response
      }
      it "returns error" do
        expect(request_response.status).to eq 422
      end
    end
  end
end
