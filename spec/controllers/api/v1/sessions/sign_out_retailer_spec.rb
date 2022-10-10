describe API::V1::Sessions::SignOutRetailer, type: :request do
  include ActiveJob::TestHelper

  let(:retailer_entity) { API::V1::Sessions::Entities::SignInRetailerEntity.new(retailer.reload) }
  let(:expected_response) { { status: 'success', data: { message: 'ok' } }.to_json }

  let!(:retailer) do
    FactoryBot.create(:retailer,
                      email: 'email@whatever.com',
                      registration_id: '124323532535',
                      password: 'dsfsdsdsd',
                      password_confirmation: 'dsfsdsdsd'
    )
  end
  let(:token) { { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true } }

  describe 'DELETE /sessions.json DESC: sign in retailer using correct credentials' do
    subject(:request_response) do
      delete '/api/v1/sessions.json', params: {}, headers: token
      response
    end

    its(:status) { is_expected.to eq 200 }
    its(:body) { is_expected.to eq expected_response }
  end

  describe "unregister" do
    let(:params) do
      {
        hardware_id: "and1234",
        registration_id: retailer.registration_id,
      }
    end
    let!(:retailer_operator) do
      create(:retailer_operator,
             retailer_id: retailer.id,
             registration_id: retailer.registration_id,
             hardware_id: "and1234"
      )
    end

    it "add uregister job" do
      expect { delete '/api/v1/sessions.json', params: params, headers: token }.to change { enqueued_jobs.size }.by(0)
    end
  end

  describe "DELETE /sessions.json DESC: doesn't log when wrong credentials are given" do
    subject(:request_response) do
      delete '/api/v1/sessions.json', params: {}, headers: { "Authentication-Token" => retailer.authentication_token + 'bad', "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 401 }
  end
end
