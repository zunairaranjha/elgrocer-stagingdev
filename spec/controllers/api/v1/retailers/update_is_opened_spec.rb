describe API::V1::Retailers::UpdateIsOpened, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  describe 'GET /retailers/update_is_opened' do
    subject(:request_response) {
      put '/api/v1/retailers/update_is_opened', params: { is_opened: false }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        retailer_data = res_data['retailer']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(retailer_data['id']).to eq retailer.id
        expect(retailer_data['email']).to eq retailer.email
        expect(retailer_data['is_opened']).to eq false
        expect(retailer_data['company_name']).to eq retailer.company_name
        expect(retailer_data['phone_number']).to eq retailer.phone_number
        expect(retailer_data['company_address']).to eq retailer.company_address
        expect(retailer_data['contact_email']).to eq retailer.contact_email
        expect(retailer_data['opening_time']).to eq retailer.opening_time
        expect(retailer_data['delivery_range']).to eq retailer.delivery_range
        expect(retailer_data['latitude']).to eq retailer.latitude
        expect(retailer_data['longitude']).to eq retailer.longitude
      end
    end
  end
end
