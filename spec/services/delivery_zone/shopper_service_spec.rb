require 'rails_helper'

describe DeliveryZone::ShopperService, type: :service do

  let(:lattitude) { 25.2386 }
  let(:longitude) { 55.2842 }
  let!(:delivery_zone) { create(:delivery_zone) }

  subject { described_class.new(longitude, lattitude) }

  describe '#find_delivery_zones' do
    it 'rerurns delivery zone' do
      expect(subject.find_delivery_zones.first).to match delivery_zone
    end
  end

  describe '#retailers_active_all' do
    let!(:retailer1) { create(:retailer, :with_delivery_zone) }
    before do
      create(:retailer_opening_hour, retailer_id: retailer1.id)
    end
    it 'rerurns delivery zone' do
      expect(subject.retailers_active_all.first).to match retailer1
    end
  end
end
