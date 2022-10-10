require 'rails_helper'

describe City, type: :model do

  describe 'associations' do
    it { expect(subject).to have_many(:locations) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:name) }
  end
end
