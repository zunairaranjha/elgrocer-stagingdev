require 'rails_helper'

describe Retailer, type: :model do

  describe 'associations' do
    it { expect(subject).to have_and_belong_to_many(:promotion_codes)}
    it { expect(subject).to have_many(:delivery_zones)}
  end

  describe '#in_delivery_zones' do
    let!(:retailer) { create(:retailer, delivery_zones: [(build(:delivery_zone))]) }
    let!(:shopper_address) { build(:shopper_address, :with_point) }

    it { expect(retailer.in_delivery_zones?(shopper_address)).to eq true }

    context 'lonlat not set' do
      let!(:shopper_address) { build(:shopper_address) }
      it { expect(retailer.in_delivery_zones?(shopper_address)).to eq false }
    end
  end

  describe '#is_opened?' do
    context 'in' do
      let!(:retailer) do
        create(:retailer,
          retailer_opening_hours: [
            create(:retailer_opening_hour,
              open: (Time.now - 3.hour).seconds_since_midnight,
              close: (Time.now + 2.hour).seconds_since_midnight
            )
          ]
        )
      end

      it { expect(retailer.is_opened?).to eq true }
    end

    context 'out' do
      let!(:retailer) do
        create(:retailer,
          retailer_opening_hours: [
            create(:retailer_opening_hour,
              open: (Time.now - 6.hour).seconds_since_midnight,
              close: (Time.now - 2.hour).seconds_since_midnight
            )
          ]
        )
      end

      it { expect(retailer.is_opened?).to eq false }
    end
  end
end
