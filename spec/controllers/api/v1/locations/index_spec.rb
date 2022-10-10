describe API::V1::Locations::Index, type: :request do
  let!(:location1) do
    FactoryBot.create(:location, {
      name: 'area1'
    })
  end

  let!(:location2) do
    FactoryBot.create(:location, {
      name: 'area2'
    })
  end

  let!(:location3) do
    FactoryBot.create(:location, {
      name: 'area3'
    })
  end

  describe 'GET /locations' do
    subject(:request_response) {
      get '/api/v1/locations', params: {}, headers: { "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    # describe 'returned countries' do
    #   subject(:responsed_countries) { JSON.parse(request_response.body)['data'] }
    #   its(:size)          { is_expected.to eq 3}
    # end
  end
end
