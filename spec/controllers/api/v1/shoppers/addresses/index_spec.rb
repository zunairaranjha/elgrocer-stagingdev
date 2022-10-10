describe API::V1::ShopperAddresses::Index, type: :request do
  let!(:shopper) do
    create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0'))
  end

  let!(:shopper_address) do
    create(:shopper_address, :with_point, shopper_id: shopper.id)
  end

  let(:token) { { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true } }

  describe 'GET /shopper_addresses DESC: get all of the shopper addresses' do
    context 'when shopper is present' do
      subject(:request_response) do
        get '/api/v1/shopper_addresses', params: {}, headers: token
        response
      end
      its(:status) { is_expected.to eq 200 }
    end

    context 'when shopper is not present' do
      let(:token) { { "Authentication-Token" => shopper.authentication_token + 'bad', "From-Spec" => true } }
      subject(:request_response) do
        get '/api/v1/shopper_addresses', params: {}, headers: token
        response
      end
      its(:status) { is_expected.to eq 401 }
    end
  end
end
