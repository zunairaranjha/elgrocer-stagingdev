describe 'API::V1::Chefs::Index', :type => :request do
  before do
    @chef = create(:chef)
  end

  context 'when condition' do
    it "get chefs" do
      get "/api/v1/chefs", params: {}, headers: { "Authentication-Token" => "36ninzmkhxHhWhxC8K8F", "From-Spec" => true }

      expect(response.status).to eq 200
      request_response = JSON.parse(response.body)
      expect(request_response['status']).to eq "success"
    end
  end
end