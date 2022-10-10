describe API::V1::Orders::Index, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:order1) do
    FactoryBot.create(:order, shopper_id: shopper.id,
                      retailer_company_name: retailer.company_name,
                      retailer_id: retailer.id,
                      shopper_note: 'Lorem ipsum dolor sit',
                      created_at: Time.now
    )
  end

  describe 'GET /orders in database' do
    context 'when params are correct' do
      subject(:request_response) do
        get '/api/v1/orders', params: {}, headers: { 'Authentication-Token' => retailer.authentication_token, "From-Spec" => true }
        response
      end

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          res_data = res['data']
          orders = res_data['orders']
          first_order = orders[0]

          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).not_to be_nil

          expect(orders.size).to eq 1

          expect(first_order['id'])
          expect(first_order['shopper_note']).to eq 'Lorem ipsum dolor sit'
          expect(first_order['retailer_company_name']).to eq order1.retailer_company_name
          expect(first_order['retailer_company_name']).to eq retailer.company_name
        end
      end
    end
  end

  describe 'GET /orders in database' do
    context 'when params are correct' do
      subject(:request_response) do
        get '/api/v1/orders', params: { status_id: 1 }, headers: { 'Authentication-Token' => retailer.authentication_token, "From-Spec" => true }
        response
      end

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          res_data = res['data']
          orders = res_data['orders']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).not_to be_nil

          expect(orders.size).to eq 0
        end
      end
    end
  end
end
