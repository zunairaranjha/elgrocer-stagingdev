describe API::V1::ShopperAddresses::Update, type: :request do
  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }

  let!(:shopper_address) { create(:shopper_address, :with_point, shopper_id: shopper.id) }

  let!(:default_shopper_address) { create(:shopper_address, :with_point,
                                          shopper_id: shopper.id, default_address: true)
  }

  let!(:shopper_address_params) do
    {
      address_name: 'FanboyPlace',
      street: "Mao's 92",
      building_name: 'ClockTower',
      apartment_number: 21,
      longitude: "128",
      latitude: "55",
      location_address: "124 Sheikh Zayed Rd- Dubai"
    }
  end

  let!(:minimal_address_params) do
    {
      address_id: shopper_address.id,
      default_address: true
    }
  end

  describe 'PUT /shopper_addresses DESC: update a shopper address' do
    before do
      allow_any_instance_of(DeliveryZone::ShopperService).to receive(:is_covered?) { true }
    end

    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: shopper_address_params.merge(address_id: shopper_address.id), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 200 }

    describe 'returned address' do
      subject(:responsed_address) { JSON.parse(request_response.body)['data']['shopper_address'] }
      its(['id']) { is_expected.to eq shopper_address.id }
      its(['address_name']) { is_expected.to eq 'FanboyPlace' }
      its(['default_address']) { is_expected.to eq false }
      its(['location_address']) { is_expected.to eq '124 Sheikh Zayed Rd- Dubai' }
      its(['longitude']) { is_expected.to eq 128.0 }
      its(['is_covered']) { is_expected.to eq true }
    end
  end

  describe 'Update a default shopper address without default address parametr' do
    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: shopper_address_params.merge(address_id: default_shopper_address.id), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      JSON.parse(response.body)['data']['shopper_address']
    end

    describe 'returned address is default' do
      its(['default_address']) { is_expected.to eq true }
    end
  end

  describe 'Update a not default shopper address to default' do
    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: shopper_address_params.merge({ address_id: shopper_address.id, default_address: true }), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      JSON.parse(response.body)['data']['shopper_address']
    end

    describe 'returned address is true' do
      its(['default_address']) { is_expected.to eq true }
    end
  end

  describe 'Update a not default shopper address to not default' do
    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: shopper_address_params.merge({ address_id: shopper_address.id, default_address: false }), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      JSON.parse(response.body)['data']['shopper_address']
    end

    describe 'returned address is true' do
      its(['default_address']) { is_expected.to eq false }
    end
  end

  describe 'Update a default shopper address to not default' do
    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: shopper_address_params.merge({ address_id: default_shopper_address.id, default_address: false }), headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      JSON.parse(response.body)['data']['shopper_address']
    end

    describe 'returned address is true' do
      its(['default_address']) { is_expected.to eq false }
    end
  end

  describe 'Update a default shopper address with minimal params' do
    subject(:request_response) do
      put '/api/v1/shopper_addresses', params: minimal_address_params, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      JSON.parse(response.body)['data']['shopper_address']
    end

    describe 'returned address is true' do
      its(['address_name']) { is_expected.to eq shopper_address.address_name }
      its(['default_address']) { is_expected.to eq true }
    end
  end
end
