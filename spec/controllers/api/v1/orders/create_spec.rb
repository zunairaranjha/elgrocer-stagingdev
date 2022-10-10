describe API::V1::Orders::Create, type: :request do
  include ActiveJob::TestHelper
  let!(:retailer) { FactoryBot.create(:retailer, delivery_zones: [delivery_zone]) }
  let!(:retailer2) { FactoryBot.create(:retailer, delivery_zones: [delivery_zone2]) }
  let!(:retailer3) { FactoryBot.create(:retailer, delivery_zones: [delivery_zone3]) }

  let(:delivery_zone) { FactoryBot.create(:delivery_zone, coordinates: 'POLYGON((55.2726 25.2388,55.2772 25.2450,55.2823 25.2422,55.2851 25.2463,55.2954 25.2396,55.3047 25.2349,55.2987 25.2259,55.2946 25.2275,55.2926 25.2253,55.2842 25.2289,55.2787 25.2348,55.2728 25.2384,55.2723 25.2390,55.2726 25.2388))') }
  let(:delivery_zone2) { FactoryBot.create(:delivery_zone, coordinates: 'POLYGON((54.2726 24.2388,54.2772 24.2450,54.2823 24.2422,54.2851 24.2463,54.2954 24.2396,54.3047 24.2349,54.2987 24.2259,54.2946 24.2275,54.2926 24.2253,54.2842 24.2289,54.2787 24.2348,54.2728 24.2384,54.2723 24.2390,54.2726 24.2388))') }
  let(:delivery_zone3) { FactoryBot.create(:delivery_zone, coordinates: 'POLYGON((55.2726 25.2388,55.2772 25.2450,55.2823 25.2422,55.2851 25.2463,55.2954 25.2396,55.3047 25.2349,55.2987 25.2259,55.2946 25.2275,55.2926 25.2253,55.2842 25.2289,55.2787 25.2348,55.2728 25.2384,55.2723 25.2390,55.2726 25.2388))') }

  let!(:available_payment_type) { FactoryBot.create(:available_payment_type) }

  let!(:shopper) { FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') }) }
  let!(:shopper_address) { FactoryBot.create(:shopper_address, lonlat: "POINT (55.2842 25.2386)", shopper_id: shopper.id) }
  let!(:shopper_address2) { FactoryBot.create(:shopper_address, lonlat: "POINT (54.2842 24.2386)", shopper_id: shopper.id) }
  let!(:shopper_address3) { FactoryBot.create(:shopper_address, lonlat: "POINT (53.2842 23.2386)", shopper_id: shopper.id) }

  let!(:shopper2) { FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') }) }
  let!(:shopper2_address) { FactoryBot.create(:shopper_address, shopper_id: shopper2.id, lonlat: "POINT (55.2842 25.2386)") }

  let!(:brand) { FactoryBot.create(:brand) }
  let!(:brand2) { FactoryBot.create(:brand) }

  let!(:product1) { FactoryBot.create(:product, brand: brand) }
  let!(:product2) { FactoryBot.create(:product, brand: brand) }
  let!(:product3) { FactoryBot.create(:product, brand: brand) }
  let!(:product4) { FactoryBot.create(:product, brand: brand2) }

  let!(:shop1) do
    FactoryBot.create(:shop, product_id: product1.id,
                      retailer_id: retailer.id, commission_value: 11, price_dollars: 2, price_cents: 99)
  end

  let!(:shop2) do
    FactoryBot.create(:shop, product_id: product2.id, retailer_id: retailer.id, price_dollars: 1, price_cents: 99)
  end

  let!(:shop3) do
    FactoryBot.create(:shop, product_id: product4.id, retailer_id: retailer.id, price_dollars: 1, price_cents: 99)
  end

  let!(:promotion_code) do
    FactoryBot.create(:promotion_code, allowed_realizations: 1, retailers: [retailer], brands: [brand])
  end

  let!(:promotion_code2) do
    FactoryBot.create(:promotion_code, allowed_realizations: 1,
                      code: '2343', retailers: [retailer], brands: [brand2], value_cents: 1000, min_basket_value: 1000)
  end

  let!(:promotion_code3) do
    FactoryBot.create(:promotion_code, allowed_realizations: 1000,
                      code: '234323', retailers: Retailer.all, brands: [brand, brand2],
                      realizations_per_shopper: 3, realizations_per_retailer: 2)
  end

  let!(:promotion_code4) do
    FactoryBot.create(:promotion_code, code: 'test_code', allowed_realizations: 1, retailers: Retailer.all, brands: [brand], value_cents: 299 * 1001, min_basket_value: 2995)
  end

  let!(:order_params1) do
    {
      retailer_id: retailer.id,
      shopper_address_id: shopper_address.id,
      payment_type_id: available_payment_type.id,
      shopper_note: 'Lorem ipsum dolor sit',
      products: [
        {
          product_id: product1.id,
          amount: 1
        },
        {
          product_id: product4.id,
          amount: 3
        }
      ]
    }
  end

  let!(:order_params2) do
    order_params1.merge(products:
                          [
                            {
                              product_id: product1.id,
                              amount: 999
                            },
                            {
                              product_id: product4.id,
                              amount: 1
                            }
                          ])
  end

  let!(:many_same_product_in_order) do
    order_params1.merge(products:
                          [
                            {
                              product_id: product1.id,
                              amount: 5
                            }
                          ])
  end

  let!(:low_basket_value_order_params) do
    order_params1.merge(
      shopper_address_id: shopper_address2.id,
      products: [
        {
          product_id: product1.id,
          amount: 1
        },
        {
          product_id: product2.id,
          amount: 2
        }
      ]
    )
  end

  let!(:check_code_params) do
    {
      retailer_id: retailer.id,
      promo_code: promotion_code.code
    }
  end

  let!(:products_brand) do
    {
      products: [
        {
          product_id: product1.id,
          amount: 1002
        }
      ]
    }
  end

  let!(:products_brand2) do
    {
      products: [
        {
          product_id: product4.id,
          amount: 1002
        }
      ]
    }
  end

  let!(:bad_shopper_address_order_params) { order_params1.merge(shopper_address_id: 983_928_398) }
  let!(:locations_is_not_covered_order_params) { order_params1.merge(shopper_address_id: shopper_address3.id) }
  let!(:create_order_in_closed_store) { order_params1.merge(retailer_id: retailer2.id) }

  before do
    create(:retailer_opening_hour, retailer_id: retailer.id, open: (Time.now - 3.hour).seconds_since_midnight, close: (Time.now + 2.hour).seconds_since_midnight)
    create(:retailer_opening_hour, retailer_id: retailer2.id, open: (Time.now - 3.hour).seconds_since_midnight, close: (Time.now - 2.hour).seconds_since_midnight)
    create(:retailer_opening_hour, retailer_id: retailer3.id, open: (Time.now - 3.hour).seconds_since_midnight, close: (Time.now + 2.hour).seconds_since_midnight)
    create(:retailer_has_available_payment_type, retailer_id: retailer.id, available_payment_type_id: available_payment_type.id)
    create(:retailer_has_available_payment_type, retailer_id: retailer2.id, available_payment_type_id: available_payment_type.id)
    create(:retailer_has_available_payment_type, retailer_id: retailer3.id, available_payment_type_id: available_payment_type.id)
    create(:shop, product_id: product1.id, retailer_id: retailer2.id, commission_value: 11, price_dollars: 2, price_cents: 99, price_currency: 'AED')
    create(:shop, product_id: product1.id, retailer_id: retailer3.id, commission_value: 11, price_dollars: 2, price_cents: 99, price_currency: 'AED')
  end

  describe 'POST /orders in database' do
    context 'when params are correct' do
      let(:token) { { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true } }
      it 'returned json contains data of product with all requested attributes' do
        post '/api/v1/orders', params: order_params1, headers: token
        expect(response.status).to eq 201
        order = json['data']['order']

        expect(json['messages']).to be_nil
        expect(json['status']).to eq 'success'
        expect(json['data']).to be_a Hash

        expect(order['shopper_note']).to eq 'Lorem ipsum dolor sit'
        expect(order['retailer_company_name']).to eq retailer.company_name
        expect(order['shopper_name']).to eq shopper.name
        expect(order['shopper_address_longitude']).to eq 55.2842
        expect(order['shopper_address_latitude']).to eq 25.2386
      end
      it "pings slack" do
        expect { post '/api/v1/orders', params: order_params1, headers: token }.to change { enqueued_jobs.size }.by(4)
        expect(enqueued_jobs.last[:args]).to match([Order.last.id])
      end

      it "pings slack" do
        expect { post '/api/v1/orders', params: order_params1, headers: token }.to change { enqueued_jobs.size }.by_at_least(1)
        expect(enqueued_jobs.last[:args]).to match([Order.last.id])
      end
    end

    context 'when params are correct but the value is lower than minimal value' do
      it 'returned json contains error data' do
        post '/api/v1/orders', params: low_basket_value_order_params, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        # do poprawy status
        expect(response.status).to eq 422

        expect(json['messages']).to be_present
        expect(json['status']).to eq "error"
        expect(json['data']).to be_nil
      end
    end

    context 'when shopper address id is invalid' do
      it 'returned json contains data of product with all requested attributes' do
        post '/api/v1/orders', params: bad_shopper_address_order_params, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(response.status).to eq 500
        expect(json['messages']).to be_present
        expect(json['status']).to eq 'error'
        expect(json['data']).to be_nil
      end
    end

    context 'when location is not covered' do
      it 'returned json contains error data' do
        post '/api/v1/orders', params: locations_is_not_covered_order_params, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        expect(response.status).to eq 422

        expect(json['messages']).to be_present
        expect(json['status']).to eq 'error'
        expect(json['data']).to be_nil
      end
    end

    context 'when we got same product in order' do
      it 'returned json contains success' do
        post '/api/v1/orders', params: many_same_product_in_order, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        expect(json['messages']).to be_nil
        expect(json['status']).to eq 'success'
      end
    end

    context 'when store is closed' do
      it 'returned json contains error' do
        post '/api/v1/orders', params: create_order_in_closed_store, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        expect(json['messages']['error_message']['retailer_is_opened']).to eq ['Shop must be open to create order']
        expect(json['status']).to eq 'error'
        expect(json['data']).to be_nil
      end
    end
  end

  describe 'POST /orders with promotion codes' do
    context "I can't use same code twice" do
      it 'returned json contains error data' do
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(products: order_params1[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_realization_id = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params1.merge(promotion_code_realization_id: promotion_code_realization_id), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(products: order_params1[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promocode_is_invalid']).to eq ['Invalid promotion code']
        expect(json['status']).to eq 'error'
      end
    end

    context "I can't use used code" do
      it 'returned json contains error data' do
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(products: order_params1[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(products: order_params1[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_2 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params1.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        post '/api/v1/orders', params: order_params1.merge(promotion_code_realization_id: promotion_code_shopper_2, shopper_address_id: shopper2_address.id), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promocode_is_valid']).to eq ['Invalid promotion code']
        expect(json['status']).to eq 'error'
      end
    end

    context "I can't use code for diffrent brand" do
      it 'returned json contains data of promotion code realization id' do
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code2.code, products: products_brand2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params1.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promotion_invalid_brands']).to eq ['Value order isnt enough to use promocode.']
        expect(json['status']).to eq 'error'
      end
    end

    context "I can't use code if value products are lower then promocode" do
      it 'returned json contains data of promotion code realization id' do
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code4.code, products: products_brand[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params2.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promotion_invalid_brands']).to eq ['Value order isnt enough to use promocode.']
        expect(json['status']).to eq 'error'
      end
    end

    context 'I can use promocode as many times shopper can use it.' do
      it 'returned json contains data of promotion code realization id' do
        2.times do
          post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
          promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
          post '/api/v1/orders', params: order_params2.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        end
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(retailer_id: retailer3.id, promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params2.merge(retailer_id: retailer3.id, promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']).to eq nil
        expect(json['status']).to eq 'success'
      end
    end

    context 'I can use promocode as many times per retailers can use it.' do
      it 'returned json contains data of promotion code realization id' do
        2.times do
          post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
          promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
          post '/api/v1/orders', params: order_params2.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        end
        expect(json['messages']).to eq nil
        expect(json['status']).to eq 'success'
      end
    end

    context "I can't use promocode above retailer limit." do
      it 'returned json contains error data' do
        2.times do
          post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
          promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
          post '/api/v1/orders', params: order_params2.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        end
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promocode_is_invalid']).to eq ['Invalid promotion code']
        expect(json['status']).to eq 'error'
      end
    end

    context "I can't use promocode above shopper limit." do
      it 'returned json contains error data' do
        2.times do
          post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
          promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
          post '/api/v1/orders', params: order_params2.merge(promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        end
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(retailer_id: retailer3.id, promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
        promotion_code_shopper_1 = JSON.parse(response.body)['data']['promotion_code_realization_id']
        post '/api/v1/orders', params: order_params2.merge(retailer_id: retailer3.id, promotion_code_realization_id: promotion_code_shopper_1), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params.merge(retailer_id: retailer3.id, promo_code: promotion_code3.code, products: order_params2[:products]), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }

        expect(json['messages']['error_message']['promocode_is_invalid']).to eq ['Invalid promotion code']
        expect(json['status']).to eq 'error'
      end
    end
  end
end
