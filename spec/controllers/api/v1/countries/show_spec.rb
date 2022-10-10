describe API::V1::Countries::Show, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  describe 'GET /countries' do
    subject(:request_response) {
      get '/api/v1/countries', params: {}, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned countries' do
      subject(:responsed_countries) { JSON.parse(request_response.body) }
      it 'contains data of all countries' do
        res = responsed_countries
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res['data']['countries']).to be_a Array
        expect(res['data']['countries'][0]['name']).not_to be_nil
      end
    end
  end

end
