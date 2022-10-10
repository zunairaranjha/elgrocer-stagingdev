require 'rails_helper'

describe Location, type: :model do

  describe 'associations' do
    [:shopper_addresses, :retailer_has_locations, :retailers].each do |field|
      it { expect(subject).to have_many(field) }
    end
    it { expect(subject).to have_many(:retailers).through(:retailer_has_locations) }
    it { expect(subject).to belong_to(:city) }
  end

  describe 'validations' do
    [:city, :name].each do |field|
      it { expect(subject).to validate_presence_of(field) }
    end
  end
end
