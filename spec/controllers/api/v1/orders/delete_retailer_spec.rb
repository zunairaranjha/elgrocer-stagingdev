describe API::V1::Orders::DeleteRetailer, type: :request do
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
      shopper_name: shopper.name,
      status_id: 3
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

  describe 'Delete /orders/accept in database' do
    context "when params are correct" do
      subject(:request_response) {
        delete '/api/v1/orders/retailer', params: { order_id: order1.id }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 204 }

      # describe 'returned json' do
      #   subject(:returned_orders) {JSON.parse(request_response.body)}
      #
      #   it 'contains data of product with all requested attributes' do
      #     res = returned_orders
      #     res_data = res['data']
      #
      #     expect(res['messages']).to be_nil
      #     expect(res['status']).to eq "success"
      #     expect(res['data']).to be_nil
      #   end
      # end
    end
  end
end