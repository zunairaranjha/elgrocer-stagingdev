require 'rails_helper'

describe Retailers::ShowProfile do
    let!(:retailer) do
        FactoryBot.create(:retailer)
    end

    context 'params are correct' do
        subject { Retailers::ShowProfile.run!({retailer_id: retailer.id}) }
        describe "returned retailer" do
            it        { is_expected.to be_instance_of Retailer}
            its(:id)  { is_expected.to eq retailer.id}
        end
    end
end