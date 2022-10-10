describe API::V1::Products::UpdateImage, type: :request do

  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:product) do
    FactoryBot.create(:product)
  end

  describe 'POST /products/:id/update_image correct data with photo' do
    subject(:request_response) do
      post '/api/v1/products/' + product.id.to_s + '/update_image', params: { :image => Rack::Test::UploadedFile.new("spec/support/images/square.png", "image/png") }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    end
    its(:status) { is_expected.to eq 201 }

    describe 'returned product' do
      subject(:responsed_product) { JSON.parse(request_response.body)['data']['product'] }
      its(['id']) { is_expected.to eq product.id }
    end
  end
end
