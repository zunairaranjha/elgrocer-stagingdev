describe API::V1::Orders::Status, type: :request do
  include ActiveJob::TestHelper
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:order1) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name
    })
  end

  let!(:order2) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      status_id: 2
    })
  end

  let!(:order3) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      status_id: 1
    })
  end

  let!(:order_position1) do
    FactoryBot.create(:order_position, {
      order_id: order3.id,
      amount: 4
    })
  end

  let!(:process_params) do
    {
      "order_id" => order3.id,
      "positions" => [
        {
          "was_in_shop" => false,
          "position_id" => order_position1.id
        }
      ]
    }
  end

  describe 'PUT /orders/deliver in database' do
    context 'params are correct' do
      subject(:request_response) {
        put '/api/v1/orders/deliver', params: { order_id: order2.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }
      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          #res_data = res['data']
          #order = res_data['order']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil

          #expect(order['retailer_company_name']).to eq retailer.company_name
          #expect(order['shopper_name']).to eq shopper.name
          #expect(order['status_id']).to eq 2
        end
      end
    end

    context 'order is not en route' do
      subject(:request_response) {
        put '/api/v1/orders/deliver', params: { order_id: order1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }
      it { expect(subject.status).to eq 452 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'responds with error' do
          res = returned_orders
          expect(res['messages']).not_to be_nil
          expect(res['status']).not_to eq "success"
          expect(res['data']).to be_nil
        end
      end
    end
  end

  describe 'PUT /orders/accept in database' do
    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/accept', params: { order_id: order1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          #res_data = res['data']
          #order = res_data['order']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil

          #expect(order['retailer_company_name']).to eq retailer.company_name
          #expect(order['shopper_name']).to eq shopper.name
          #expect(order['status_id']).to eq 1
          # expect(enqueued_jobs.first[:args]).to match ["ShopperMailer", "order_placement", "deliver_now", order1.id]
        end
      end
    end
  end

  describe 'PUT /orders/process in database' do
    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/process', params: process_params, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          #res_data = res['data']
          #order = res_data['order']
          #order_positions = order['order_positions']
          #first_order_position = order_positions[0]

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil

          #expect(order['retailer_company_name']).to eq retailer.company_name
          #expect(order['shopper_name']).to eq shopper.name
          #expect(order['status_id']).to eq 2

          #expect(first_order_position['id']).to eq order_position1.id
          #expect(first_order_position['was_in_shop']).to eq process_params['positions'][0]['was_in_shop']
        end
      end
    end
  end

  describe 'PUT /orders/accept in database' do
    context "when params are correct but order is already accepted" do
      subject(:request_response) {
        put '/api/v1/orders/accept', params: { order_id: order3.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 452 }
      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders

          expect(res['messages']).not_to be_nil
          expect(res['status']).not_to eq "success"
          expect(res['data']).to be_nil
        end
      end
    end
  end
end
