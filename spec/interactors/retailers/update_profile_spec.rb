require 'rails_helper'

describe Retailers::UpdateProfile do
  let!(:retailer) do
    FactoryBot.create(:retailer, {
      authentication_token: 'abc'
    })
  end

  let!(:location) do
    FactoryBot.create(:location)
  end

  let(:new_company) {
    {
      company_name: "New name",
      company_address: "New address",
      location_id: location.id,
      street: 'zjechal',
      building: 'bigbuilding',
      apartment: 'h23',
      flat_number: '2',
      phone_number: "777666555",
      email: "email@exmple.com",
      contact_email: "newemail#@example.com",
      opening_time: '{"closing_hours":["12:00","23:00","23:00"],"opening_days":[true,true,true],"opening_hours":["01:00","07:00","07:00"]}',
      delivery_range: 30,
      latitude: 24.234432,
      longitude: -23.34242
    }
  }

  context 'params are correct' do
      subject { Retailers::UpdateProfile.run!(new_company.merge({retailer_id: retailer.id})) }
      describe "returned retailer" do
          it        { is_expected.to be_instance_of Retailer}
          its(:id)  { is_expected.to eq retailer.id}
      end
  end
end
