describe API::V1::Brands::New, type: :request do
  let!(:retailer) { create(:retailer) }


  describe 'GET /brands' do
    subject(:request_response) {
      post '/api/v1/brands', params: {name: "Nestle"}, headers: {"Authentication-Token" => retailer.authentication_token , "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      subject(:returned_data) {JSON.parse(request_response.body)}

      it 'contains data of product with all requested attributes' do
        res = returned_data
        res_data = res['data']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data['brand']['name']).to eq "Nestle"
      end
    end
  end


end
