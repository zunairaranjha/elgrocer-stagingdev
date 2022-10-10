describe API::V1::Orders::Status, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:order1) do
    Delorean.jump -20.minutes
    order = FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      created_at: Time.now,
      status_id: 0
    })
    Delorean.jump 20.minutes
    order
  end

  let!(:order2) do
    Delorean.jump -20.minutes
    order = FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      created_at: Time.now,
      status_id: 2
    })
    Delorean.jump 20.minutes
    order
  end

  let!(:order3) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      status_id: 2
    })
  end

  describe 'PUT /orders/cancel in database' do
    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/cancel', params: { order_id: order1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil
        end
      end
    end

    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/cancel', params: { order_id: order1.id, message: "No resources. Sorry!" }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil
        end
      end
    end

    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/cancel', params: { order_id: order1.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders
          #returned_order = res['data']['order']

          expect(res['messages']).to be_nil
          expect(res['status']).to eq "success"
          expect(res['data']).not_to be_nil
          #expect(returned_order['status_id']).to eq 4
          #expect(returned_order['id']).to eq order1.id
        end
      end
    end

    context "When order do not exists" do
      subject(:request_response) {
        put '/api/v1/orders/cancel', params: { order_id: 922234 }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 404 }
      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders

          expect(res['messages']).not_to be_nil
          expect(res['status']).to eq "error"
          expect(res['data']).to be_nil
        end
      end
    end

    context "When order do not exists" do
      subject(:request_response) {
        put '/api/v1/orders/cancel', params: { order_id: 922234 }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 404 }
      describe 'returned json' do
        subject(:returned_orders) { JSON.parse(request_response.body) }

        it 'contains data of product with all requested attributes' do
          res = returned_orders

          expect(res['messages']).not_to be_nil
          expect(res['status']).to eq "error"
          expect(res['data']).to be_nil
        end
      end
    end

    # context "When the order's status is not set to 'pending'" do
    #   subject(:request_response) {
    #     put '/api/v1/orders/cancel', params: {order_id: order2.id}, headers: {"Authentication-Token" => retailer.authentication_token}
    #     response
    #   }
    #
    #   it { expect(subject.status).to eq 422 }
    #   describe 'returned json' do
    #     subject(:returned_orders) {JSON.parse(request_response.body)}
    #
    #     it 'contains data of product with all requested attributes' do
    #       res = returned_orders
    #
    #       expect(res['messages']).not_to be_nil
    #       expect(res['status']).to eq "error"
    #       expect(res['data']).to be_nil
    #     end
    #   end
    # end

    # context "When the order's status is not set to 'pending'" do
    #   subject(:request_response) {
    #     put '/api/v1/orders/cancel', params: {order_id: order2.id}, headers: {"Authentication-Token" => shopper.authentication_token}
    #     response
    #   }
    #
    #   it { expect(subject.status).to eq 422 }
    #   describe 'returned json' do
    #     subject(:returned_orders) {JSON.parse(request_response.body)}
    #
    #     it 'contains data of product with all requested attributes' do
    #       res = returned_orders
    #
    #       expect(res['messages']).not_to be_nil
    #       expect(res['status']).to eq "error"
    #       expect(res['data']).to be_nil
    #     end
    #   end
    # end
  end
end