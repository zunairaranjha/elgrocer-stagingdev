require 'rails_helper'

describe API::V1::Retailers::CheckIfOnline, type: :request do
  let(:params) do
    { latitude: 25.2386, longitude: 55.2842 }
  end
  let!(:retailer1) { create(:retailer, delivery_zones: [delivery_zone]) }
  let!(:retailer2) { create(:retailer, delivery_zones: [delivery_zone2]) }
  let(:delivery_zone) { create(:delivery_zone, coordinates: 'POLYGON((55.2726 25.2388,55.2772 25.2450,55.2823 25.2422,55.2851 25.2463,55.2954 25.2396,55.3047 25.2349,55.2987 25.2259,55.2946 25.2275,55.2926 25.2253,55.2842 25.2289,55.2787 25.2348,55.2728 25.2384,55.2723 25.2390,55.2726 25.2388))') }
  let(:delivery_zone2) { create(:delivery_zone, coordinates: 'POLYGON((54.2726 24.2388,54.2772 24.2450,54.2823 24.2422,54.2851 24.2463,54.2954 24.2396,54.3047 24.2349,54.2987 24.2259,54.2946 24.2275,54.2926 24.2253,54.2842 24.2289,54.2787 24.2348,54.2728 24.2384,54.2723 24.2390,54.2726 24.2388))') }

  before do
    create(:retailer_opening_hour, retailer_id: retailer1.id)
    create(:retailer_opening_hour, retailer_id: retailer2.id,
           open: (Time.now - 3.hour).seconds_since_midnight,
           close: (Time.now - 2.hour).seconds_since_midnight
    )
  end

  describe 'GET /retailers/are_online in database' do
    context "when shopper in delivery_zones where are opened stores" do
      subject(:request_response) {
        get '/api/v1/retailers/are_online', params: params, headers: { "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_retailers) { JSON.parse(request_response.body) }

        it 'contains confirmation data' do
          res = returned_retailers

          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).to eq true
        end
      end
    end

    context "when shopper in delivery_zones where are closed stores" do
      let(:params) do
        { latitude: 24.2386, longitude: 54.2842 }
      end

      subject(:request_response) {
        get '/api/v1/retailers/are_online', params: params, headers: { "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 200 }

      describe 'returned json' do
        subject(:returned_retailers) { JSON.parse(request_response.body) }

        it 'contains confirmation data' do
          res = returned_retailers

          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).to eq false
        end
      end
    end
  end
end
