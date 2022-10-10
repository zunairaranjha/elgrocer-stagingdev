describe API::V1::Sessions::SignInShopper, type: :request do
  let(:shopper_entity) { API::V1::Sessions::Entities::SignInShopperEntity.new(shopper.reload) }
  let(:expected_response) { { status: 'success', data: { shopper: shopper_entity } }.to_json }

  let(:email) { "exampleshopper@dubai.com" }
  let(:password) { "password" }
  let(:registration_id) { "GRdsd53-3sdgbBFG-23sd" }
  let(:device_type) { 1 }

  let!(:shopper) do
    FactoryBot.create(:shopper,
                      :email => email,
                      :password => password,
                      :phone_number => Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')
    )
  end

  before(:each) do
    post '/api/v1/sessions/shopper.json', params: { password: password, email: email, registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
    shopper.reload
  end

  it { expect(shopper.current_sign_in_at).to be_present }

  describe 'POST /sessions/shopper.json DESC: sign in shopper using correct credentials' do
    subject(:request_response) do
      post '/api/v1/sessions/shopper.json', params: { password: password, email: email, registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 201 }
    its(:body) { is_expected.to eq expected_response }
  end

  describe "POST /api/v1/sessions/shopper.json DESC: doesn't log when wrong credentials are given" do
    subject(:request_response) do
      post '/api/v1/sessions/shopper.json', params: { password: password, email: "wrong@example.com", registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 403 }
  end

end
