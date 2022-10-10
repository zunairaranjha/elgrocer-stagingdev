describe API::V1::Favourites::IndexRetailers, type: :request do
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

  describe 'GET /favourite/retailers' do
    subject(:request_response) {
      get '/api/v1/favourites/retailers', params: {}, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        retailer_data = res_data['retailers'][0]
        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash
        expect(retailer_data["company_name"]).to eq retailer.company_name
        expect(retailer_data["is_favourite"]).to eq true
      end
    end
  end

end
