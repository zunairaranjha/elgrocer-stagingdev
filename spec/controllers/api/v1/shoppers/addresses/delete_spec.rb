describe API::V1::ShopperAddresses::Delete, type: :request do
  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }

  let!(:shopper_address) { create(:shopper_address, shopper_id: shopper.id) }

  let!(:default_shopper_address) { create(:shopper_address, shopper_id: shopper.id, default_address: true) }

  describe 'DELETE /shopper_addresses DESC: delete a shopper address' do
    subject(:request_response) do
      delete '/api/v1/shopper_addresses', params: { address_id: shopper_address.id }, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to be_between(200, 299) }

    # describe 'returned json' do
    #   subject(:returned_orders) { JSON.parse(request_response.body) }
    #   its(['status']) { is_expected.to eq 'success' }
    #   its(['messages']) { is_expected.to eq nil }
    #   its(['data']) { is_expected.to eq nil }
    # end
  end

  describe 'DELETE /shopper_addresses DESC: delete a default shopper address' do
    subject(:request_response) do
      delete '/api/v1/shopper_addresses', params: { address_id: default_shopper_address.id }, headers: { 'Authentication-Token' => shopper.authentication_token, "From-Spec" => true }
      response
    end

    it 'cannot remove default address' do
      res = JSON.parse(subject.body)
      expect(res['status']).to eq 'error'
      expect(res['messages']).to eq 'Cannot delete default address!'
      expect(subject.status).to eq 500
    end
  end
end
