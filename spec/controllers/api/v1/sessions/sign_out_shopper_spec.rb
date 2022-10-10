describe API::V1::Sessions::SignOutShopper, type: :request do
  let(:retailer_entity) { API::V1::Sessions::Entities::SignInRetailerEntity.new(retailer.reload) }
  let(:expected_response) { { status: 'success', data: { message: 'ok' } }.to_json }

  let!(:shopper) do
    FactoryBot.create(:shopper,
                      email: 'email@whatever.com',
                      password: 'dsfsdsdsd',
                      password_confirmation: 'dsfsdsdsd',
                      phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')
    )
  end

  describe 'DELETE /sessions/shopper.json DESC: sign in retailer using correct credentials' do
    subject(:request_response) do
      delete '/api/v1/sessions/shopper', params: {}, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 200 }
    its(:body) { is_expected.to eq expected_response }
  end

  describe "DELETE /sessions.json DESC: doesn't log when wrong credentials are given" do
    subject(:request_response) do
      delete '/api/v1/sessions/shopper', params: {}, headers: { "Authentication-Token" => shopper.authentication_token + 'bad', "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 401 }
  end

end
