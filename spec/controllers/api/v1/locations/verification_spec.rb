describe API::V1::Locations::Verification, type: :request do
  let!(:location1) { create(:location, name: 'area1') }
  let!(:location2) { create(:location, name: 'area2') }
  let!(:location3) { create(:location, name: 'area3') }

  describe 'POST /locations/verification' do
    subject(:request_response) {
      post '/api/v1/locations/verification', params: { location_id: location1.id }, headers: { "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      it 'contains data of location id' do
        res = JSON.parse(subject.body)
        expect(res['status']).to eq 'success'

        expect(res['data']).to eq location1.id
      end
    end
  end

  describe 'POST /locations/verification' do
    before do
      @retailer = create(:retailer, location_id: location2.id)
      @retailer_has_location = create(:retailer_has_location, location_id: location2.id, retailer_id: @retailer.id)
      shopper = create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
      @shopper_address = create(:shopper_address, shopper_id: shopper.id, location_id: location2.id)
      @product = create(:product, location_id: location2.id)
      location3.set_primary(location2)
      location2.set_primary(location1)
    end

    subject(:request_response) {
      post '/api/v1/locations/verification', params: { location_id: location2.id }, headers: { "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      it 'contains data of location id' do
        res = JSON.parse(subject.body)

        expect(res['status']).to eq 'success'
        expect(res['data']).to eq location1.id
      end

      it 'deactivate location updates location to primary in dependency objects' do
        expect(@retailer.reload.location_id).to eq location1.id
        expect(@retailer_has_location.reload.location_id).to eq location1.id
        expect(@shopper_address.reload.location_id).to eq location1.id
        expect(@product.reload.location_id).to eq location1.id
        expect(location3.reload.primary_location_id).to eq location1.id
      end
    end
  end
end
