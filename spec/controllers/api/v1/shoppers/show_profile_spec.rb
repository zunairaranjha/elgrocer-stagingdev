describe API::V1::Shoppers::ShowProfile, type: :request do
  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }

  let!(:shopper_address) { create(:shopper_address, shopper_id: shopper.id) }

  describe 'GET /shoppers/ DESC: get shopper profile' do
    subject(:request_response) do
      get '/api/v1/shoppers/show_profile', params: {}, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end
    its(:status) { is_expected.to eq 200 }

    describe 'returned profile' do
      subject(:responsed_shopper) { JSON.parse(request_response.body)['data']['shopper'] }
      its(['id']) { is_expected.to eq shopper.id }
      its(['email']) { is_expected.to eq shopper.email }
      its(['phone_number']) { is_expected.to eq shopper.phone_number }
      its(['name']) { is_expected.to eq shopper.name }
      its(['default_address_id']) { is_expected.to eq 0 }
    end

    describe 'returned profile with default_address' do
      let!(:shopper_address2) { create(:shopper_address, shopper_id: shopper.id, default_address: true) }

      subject(:responsed_shopper) do
        JSON.parse(request_response.body)['data']['shopper']
      end

      its(['default_address_id']) { is_expected.to eq shopper_address2.id }
    end
  end
end
