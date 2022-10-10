describe API::V1::Retailers::UpdateProfile, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:location) do
    FactoryBot.create(:location)
  end

  let(:new_company) {
    {
      company_name: "New name",
      company_address: "New address",
      street: 'zjechal',
      building: 'bigbuilding',
      apartment: 'h23',
      flat_number: '2',
      phone_number: "777666555",
      email: "email@exmple.com",
      contact_email: "newemail#@example.com",
      opening_time: '{"closing_hours":["12:00","23:00","23:00"],"opening_days":[true,true,true],"opening_hours":["01:00","07:00","07:00"]}',
      delivery_range: 30,
      latitude: 24.234432,
      longitude: -23.34242
    }
  }

  describe 'PUT /retailers/update correct data' do
    subject(:request_response) {
      put '/api/v1/retailers/update', params: new_company.merge({ retailer_id: retailer.id }), headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }

    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of retailer with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        retailer_data = res_data['retailer']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq 'success'
        expect(res['data']).to be_a Hash

        expect(retailer_data['id']).to eq retailer.id
        expect(retailer_data['email']).to eq new_company[:email]
        expect(retailer_data['company_name']).to eq new_company[:company_name]
        expect(retailer_data['phone_number']).to eq new_company[:phone_number]
        expect(retailer_data['company_address']).to eq new_company[:company_address]
        expect(retailer_data['contact_email']).to eq new_company[:contact_email]
        expect(retailer_data['opening_time']).to eq new_company[:opening_time]
        expect(retailer_data['delivery_range']).to eq new_company[:delivery_range]
        expect(retailer_data['latitude']).to eq new_company[:latitude]
        expect(retailer_data['longitude']).to eq new_company[:longitude]
      end
    end

    describe 'update retailer' do
      subject(:update_location) {
        put '/api/v1/retailers/update', params: new_company.merge({ retailer_id: retailer.id, location_id: location.id }), headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
        JSON.parse(response.body)
      }

      it 'return retailer with new location' do
        res = subject
        retailer.reload

        expect(res['messages']).to be_nil
        expect(res['status']).to eq 'success'
        expect(res['data']).to be_a Hash

        expect(res['data']['retailer']['id']).to eq retailer.id
        expect(retailer.location_id).to eq location.id
      end
    end
  end
end
