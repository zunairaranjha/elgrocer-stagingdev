describe API::V1::Retailers::ShowProfile, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer, delivery_zones: [
      build(:delivery_zone, coordinates: coordinates),
      build(:delivery_zone, coordinates: coordinates2)
    ]
    )
  end
  let(:coordinates) { 'POLYGON((55.2726 25.2388,55.2772 25.2450,55.2723 25.2390,55.2726 25.2388))' }
  let(:coordinates2) { 'POLYGON((54.2726 24.2388,54.2772 24.2450,54.2723 24.2390,54.2726 24.2388))' }

  let(:delivery_areas) do
    [
      [
        { "longitude" => 55.2726, "latitude" => 25.2388 },
        { "longitude" => 55.2772, "latitude" => 25.245 },
        { "longitude" => 55.2723, "latitude" => 25.239 },
        { "longitude" => 55.2726, "latitude" => 25.2388 }
      ],
      [
        { "longitude" => 54.2726, "latitude" => 24.2388 },
        { "longitude" => 54.2772, "latitude" => 24.245 },
        { "longitude" => 54.2723, "latitude" => 24.239 },
        { "longitude" => 54.2726, "latitude" => 24.2388 }
      ]
    ]
  end
  describe 'GET /retailers/show_profile' do
    subject(:request_response) {
      get '/api/v1/retailers/', params: { retailer_id: retailer.id }, headers: { "From-Spec" => true }
      # puts(JSON.parse(response.body))
      response
    }
    it { expect(subject.status).to eq 200 }

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
        expect(retailer_data['email']).to eq retailer.email
        expect(retailer_data['company_name']).to eq retailer.company_name
        expect(retailer_data['phone_number']).to eq retailer.phone_number
        expect(retailer_data['company_address']).to eq retailer.company_address
        expect(retailer_data['contact_email']).to eq retailer.contact_email
        expect(retailer_data['opening_time']).to eq retailer.opening_time
        expect(retailer_data['delivery_range']).to eq retailer.delivery_range
        expect(retailer_data['latitude']).to eq retailer.latitude
        expect(retailer_data['longitude']).to eq retailer.longitude
        expect(retailer_data['delivery_areas']).to match delivery_areas
      end
    end
  end

  describe 'GET profile of non-existent retailer' do
    subject(:request_response) {
      get '/api/v1/retailers', params: { retailer_id: 6 }, headers: { "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 403 }
  end
end
