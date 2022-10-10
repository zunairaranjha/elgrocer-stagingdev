describe API::V1::Brands::Show, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:brand) do
    FactoryBot.create(:brand)
  end

  describe 'GET /brands' do
    subject(:request_response) {
      get '/api/v1/brands', params: {limit: 1, offset: 0}, headers: {"Authentication-Token" => retailer.authentication_token , "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_data) {JSON.parse(request_response.body)}

      it 'contains data of product with all requested attributes' do
        res = returned_data
        res_data = res['data']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data['brands'].size).to eq 1
        expect(res_data['next']).to eq false
      end
    end
  end


end
