describe API::V1::Shoppers::UpdateInvoiceAddress, type: :request do

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:location) do
    FactoryBot.create(:location, {
      name: 'Downtown'
    })
  end

  describe 'PUT /shoppers/invoice_address DESC: update shopper invoice address' do
    subject(:request_response) do
      put '/api/v1/shoppers/invoice_address', params: {
        invoice_address_name: "FanboyPlace",
        invoice_city: "Hogwart",
        invoice_area: "Upper",
        invoice_street: "Mao's 92",
        invoice_building_name: "ClockTower",
        invoice_apartment_number: 21,
        invoice_floor_number: 2,
        invoice_location_id: location.id
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

    describe 'returned address' do
      subject(:responsed_address) { JSON.parse(request_response.body)['data']['shopper'] }
      its(['id']) { is_expected.to eq shopper.id }
      its(['invoice_city']) { is_expected.to eq "Hogwart" }
      its(['invoice_location_name']) { is_expected.to eq location.name }
    end
  end

end