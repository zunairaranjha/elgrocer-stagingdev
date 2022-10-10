describe API::V1::Retailers::UpdatePhoto, type: :request do

  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  describe 'POST /retailers/update_photo correct data with photo' do
    subject(:request_response) do
      post '/api/v1/retailers/update_photo', params: { :photo => Rack::Test::UploadedFile.new("spec/support/images/square.png", "image/png") }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    end
    its(:status) { is_expected.to eq 201 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        retailer_data = res_data['retailer']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(retailer_data['id']).to eq retailer.id
      end
    end
  end

  describe 'POST update photo of non-existent retailer' do
    subject(:request_response) do
      post '/api/v1/retailers/update_photo', params: { :photo => Rack::Test::UploadedFile.new("spec/support/images/square.png", "image/png") }, headers: { "Authentication-Token" => retailer.authentication_token + 'bad', "From-Spec" => true }
      response
    end
    its(:status) { is_expected.to eq 401 }
  end
end
