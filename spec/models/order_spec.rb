require 'rails_helper'

describe Order, type: :model do

  describe 'associations' do
    it { expect(subject).to have_one(:promotion_code_realization)}
  end
end
