describe API::V1::Sessions::SignInRetailer, type: :request do
  let(:retailer_entity) { API::V1::Sessions::Entities::SignInRetailerEntity.new(retailer.reload) }
  let(:expected_response) { { status: 'success', data: { retailer: retailer_entity } }.to_json }

  let(:email) { "retailer@example.com" }
  let(:password) { "awesomeapss" }
  let(:registration_id) { "GRDb53-3sdgbBFG-23sd" }
  let(:device_type) { 0 }

  let!(:retailer) do
    FactoryBot.create(:retailer,
                      email: email,
                      password: password,
                      password_confirmation: password
    )
  end

  before(:each) do
    post '/api/v1/sessions.json', params: { password: password, email: email, registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
    retailer.reload
  end

  it { expect(retailer.current_sign_in_at).to be_present }

  describe 'POST /sessions.json DESC: sign in retailer using correct credentials' do
    subject(:request_response) do
      post '/api/v1/sessions.json', params: { password: password, email: email, registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 201 }
    its(:body) { is_expected.to eq expected_response }
  end

  describe "POST /sessions.json DESC: doesn't log when wrong credentials are given" do
    subject(:request_response) do
      post '/api/v1/sessions.json', params: { password: password, email: "wrong@example.com", registration_id: registration_id, device_type: device_type }, headers: { "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 403 }
  end

end
