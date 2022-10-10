describe API::V1::Shoppers::Update, type: :request do

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:location) do
    FactoryBot.create(:location)
  end

  let!(:shopper_address) do
    FactoryBot.create(:shopper_address, shopper_id: shopper.id, location_id: location.id)
  end

  describe 'PUT /shoppers/update DESC: sign in retailer using correct credentials' do
    subject(:request_response) do
      put '/api/v1/shoppers/update', params: {
        :password => "password",
        :password_confirmation => "password",
        :name => "Bob Example2",
        :phone_number => "666999888",
        :email => "example@dubai.com"
      }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    end

    its(:status) { is_expected.to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }
      its(['status']) { is_expected.to eq "success" }
      its(['messages']) { is_expected.to eq nil }
      its(['data']) { is_expected.to be_instance_of Hash }
    end

    describe 'returned retailer' do
      subject(:responsed_shopper) { JSON.parse(request_response.body)['data']['shopper'] }
      its(['id']) { is_expected.to eq shopper.id }
      its(['email']) { is_expected.to eq "example@dubai.com" }
      # its(['phone_number'])       { is_expected.to eq "666999888" }
      # its(['name'])               { is_expected.to eq "Bob Example2" }
    end
  end

end
