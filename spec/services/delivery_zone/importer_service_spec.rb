require 'rails_helper'

describe DeliveryZone::ImporterService, type: :service do
  def kml_data_path(filename)
    Rails.root.join('spec/fixtures/kml', filename)
  end

  subject { described_class.new(kml_data_path('polygon_g.kml')) }


  describe 'coordinates' do
    let(:coordinates) do
      '55.1371622 25.0693513,55.1386857 25.0630926,55.1470757 25.0711783,55.14184 25.0735494,55.1371622 25.0693513'
    end

    it 'returns coords' do
      expect(subject.send(:coordinates)).to eq coordinates
    end
  end

  describe 'name' do
    it 'returns name' do
      expect(subject.send(:name)).to eq 'Test Area Mickael JLT'
    end
  end

  describe 'color' do
    it 'returns color' do
      expect(subject.send(:color)).to eq 'ff000000'
    end
  end

  describe 'width' do
    it 'returns width' do
      expect(subject.send(:width)).to eq 1
    end
  end

  describe 'perform' do
    it 'creates zone' do
      expect { subject.perform }.to change(DeliveryZone, :count).by(1)
      expect(DeliveryZone.first.coordinates).to be_kind_of(RGeo::Geos::CAPIPolygonImpl)
    end
  end
end
