require 'rails_helper'

describe PromotionCodeRealization, type: :model do

  describe 'associations' do
    [:promotion_code, :shopper, :order].each do |field|
      it { expect(subject).to belong_to(field) }
    end
  end

  describe 'validations' do
    [:promotion_code, :shopper, :realization_date].each do |field|
      it { expect(subject).to validate_presence_of(field) }
    end
  end
end
