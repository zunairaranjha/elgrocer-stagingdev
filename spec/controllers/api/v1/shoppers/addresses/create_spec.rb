describe API::V1::ShopperAddresses::Update, type: :request do
  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }

  let!(:shopper_address) { create(:shopper_address, shopper_id: shopper.id, default_address: true) }

  let!(:shopper_address2) { create(:shopper_address, shopper_id: shopper.id) }

  let!(:shopper_address_params) do
    {
      address_name: "FanboyPlace",
      street: "Mao's 92",
      building_name: "ClockTower",
      apartment_number: 21,
      longitude: 128.0,
      latitude: 55.0,
      location_address: "124 Sheikh Zayed Rd- Dubai"
    }
  end

  describe 'PUT /shopper_addresses DESC: update a shopper address' do
    subject(:request_response) do
      post '/api/v1/shopper_addresses', params: shopper_address_params, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 201 }

    describe 'returned address' do
      subject(:responsed_address) { JSON.parse(request_response.body)['data']['shopper_address'] }
      its(['address_name']) { is_expected.to eq 'FanboyPlace' }
      its(['location_address']) { is_expected.to eq '124 Sheikh Zayed Rd- Dubai' }
      its(['longitude']) { is_expected.to eq 128.0 }
    end
  end

  describe 'PUT /shopper_addresses DESC: create shopper address with default address' do
    subject(:request_response) do
      post '/api/v1/shopper_addresses', params: shopper_address_params.merge(default_address: true), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end

    it 'new address is default' do
      res = JSON.parse(subject.body)
      expect(res['data']['shopper_address']['id']).to eq shopper.default_address.id
      expect(subject.status).to eq 201
    end
  end
end
