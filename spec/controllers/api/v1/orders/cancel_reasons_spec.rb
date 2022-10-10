describe API::V1::Orders::CancelReasons, type: :request do

  let!(:cancel_reason) do
    FactoryBot.create(:system_configuration)
  end

  context 'When Conditions are true' do
    it 'get Orders Reasons' do
      get '/api/v1/orders/cancel/reasons', params: {}, headers: { 'From-Spec' => true }

      expect(response.status).to eq 200
      request_response = JSON.parse(response.body)
      expect(request_response['status']).to eq 'success'
    end
  end
end
