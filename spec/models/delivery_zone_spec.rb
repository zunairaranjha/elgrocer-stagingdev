require 'rails_helper'

describe DeliveryZone, type: :model do

  describe 'associations' do
    it { expect(subject).to have_many(:retailers) }
  end

  describe ".with_point" do
    let!(:delivery_zone){ create(:delivery_zone) }
    let!(:delivery_zone2) do
      FactoryBot.create(:delivery_zone,
        coordinates: 'POLYGON((54.2726 24.2388,54.2772 24.2450,54.2728 24.2384,54.2723 24.2390,54.2726 24.2388))')
    end
    let(:point) { 'POINT (55.2842 25.2386)' }

    it { expect(DeliveryZone.with_point(point)).to match([delivery_zone])}
  end

  describe "#to_lonlat_array" do
    let!(:delivery_zone) do
      FactoryBot.create(:delivery_zone,
        coordinates: 'POLYGON((54.2726 24.2388,54.2772 24.2450,54.2728 24.2384,54.2723 24.2390,54.2726 24.2388))')
    end
    let(:expected_array) do
      [
        {:longitude=>54.2726, :latitude=>24.2388},
        {:longitude=>54.2772, :latitude=>24.245},
        {:longitude=>54.2728, :latitude=>24.2384},
        {:longitude=>54.2723, :latitude=>24.239},
        {:longitude=>54.2726, :latitude=>24.2388}
      ]
    end

    it { expect(delivery_zone.to_lonlat_array).to match(expected_array) }
  end
end
