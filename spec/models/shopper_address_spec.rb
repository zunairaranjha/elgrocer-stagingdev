require 'rails_helper'

describe ShopperAddress, type: :model do
  describe "lonlat" do
    context 'has cooridates' do
      let(:shopper_address) { build(:shopper_address,  lonlat: 'POINT (10.0059731 20.7143528)') }

      it { expect(shopper_address.lonlat).to be_kind_of(RGeo::Geos::CAPIPointImpl) }
      it { expect(shopper_address.lonlat.to_s).to eq('POINT (10.0059731 20.7143528)') }
      it { expect(shopper_address.longitude).to eq(10.0059731) }
      it { expect(shopper_address.latitude).to eq(20.7143528) }
    end
  end
end
