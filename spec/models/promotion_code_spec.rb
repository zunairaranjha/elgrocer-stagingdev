require 'rails_helper'

describe PromotionCode, type: :model do

  describe 'associations' do
    it { expect(subject).to have_many(:realizations) }
    it { expect(subject).to have_and_belong_to_many(:retailers) }
  end

  describe 'validations' do
    let!(:retailer) { FactoryBot.create(:retailer) }
    let!(:brand) { FactoryBot.create(:brand) }
    subject { FactoryBot.create(:promotion_code, retailers: [retailer], brands: [brand]) }
    it { expect(subject).to validate_uniqueness_of(:code).case_insensitive}
    it { expect(subject).to validate_numericality_of(:allowed_realizations).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_numericality_of(:allowed_realizations).is_less_than_or_equal_to(999999) }
    it { expect(subject).to validate_numericality_of(:value_cents).is_greater_than(0) }
    [:value_cents, :value_currency, :allowed_realizations, :code].each do |field|
      it { expect(subject).to validate_presence_of(field) }
    end
  end
end
