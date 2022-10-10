describe API::V1::Favourites::DeleteRetailer, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:shopper_favourite_retailer) do
    FactoryBot.create(:shopper_favourite_retailer, {
      shopper_id: shopper.id,
      retailer_id: retailer.id
    })
  end

  describe 'DELETE /favourite/retailers' do
    subject(:request_response) {
      delete '/api/v1/favourites/retailers', params: { retailer_id: retailer.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(res_data['message']).not_to be_nil
      end
    end
  end

end
