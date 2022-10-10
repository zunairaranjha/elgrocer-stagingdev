describe API::V1::Orders::Approve, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:shopper2) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:order1) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name,
      status_id: 2
    })
  end

  describe 'PUT /orders/accept in database' do
    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/approve', params: { order_id: order1.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
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
          #expect(res['data']).to be_a Hash
          #expect(order['retailer_company_name']).to eq retailer.company_name
          #expect(order['shopper_name']).to eq shopper.name
          #expect(order['is_approved']).to eq true
        end
      end
    end
  end

  describe 'PUT /orders/accept in database' do
    context "when params are correct" do
      subject(:request_response) {
        put '/api/v1/orders/approve', params: { order_id: order1.id }, headers: { "Authentication-Token" => shopper2.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 422 }
    end
  end

end
