require 'rails_helper'

describe API::V1::Retailers::Index, type: :request do
  let!(:retailer1) { create(:retailer, :with_delivery_zone) }
  let!(:retailer2) { create(:retailer, :with_delivery_zone) }
  let!(:retailer3) { create(:retailer, :with_delivery_zone) }
  let!(:retailer4) { create(:retailer, :with_delivery_zone) }

  let(:params) do
    { latitude: 25.2386, longitude: 55.2842, limit: 10, offset: 0 }
  end

  before do
    retailer1.retailer_delivery_zones.first.update_attribute(:min_basket_value, 5.55)
    create(:retailer_opening_hour, retailer_id: retailer1.id)
    create(:retailer_opening_hour, retailer_id: retailer2.id)
    create(:retailer_opening_hour, retailer_id: retailer3.id)
    create(:retailer_opening_hour, retailer_id: retailer4.id,
           open: (Time.now - 3.hour).seconds_since_midnight,
           close: (Time.now - 2.hour).seconds_since_midnight
    )
  end

  describe 'GET /retailers/all in database' do
    context "when params are correct" do
      subject(:request_response) {
        get '/api/v1/retailers/all', params: params, headers: { "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_retailers) { JSON.parse(request_response.body) }

        it 'contains data of opening retailers' do
          res = returned_retailers

          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']['retailers'].count).to eq 3
          expect(res['data']['retailers'].first['min_basket_value']).to eq 5.55
        end
      end
    end
  end
end
