require "rails_helper"

describe ShopperMailer do
  describe "#order_placement" do
    let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }
    let!(:retailer) { create(:retailer) }
    let!(:order) { create(:order, shopper: shopper, retailer: retailer) }
    let!(:order_position) { create(:order_position, order_id: order.id, amount: 4) }
    let(:mail) { ShopperMailer.order_placement(order.id).deliver_now }

    before do
      allow_any_instance_of(OrderPosition).to receive(:product_image_url) { "http://url" }
      mail
    end

    it "renders email" do
      expect(mail.to).to eql([order.shopper.email])
    end

    it "delivers message" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end

  describe "#welcome_shopper" do
    let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }
    let(:mail) { ShopperMailer.welcome_shopper(shopper.id).deliver_now }

    before do
      mail
    end

    it "renders email" do
      expect(mail.to).to eql([shopper.email])
    end

    it "delivers message" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end

  describe "#password_reset" do
    let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')) }
    let(:mail) { ShopperMailer.password_reset(shopper.id).deliver_now }

    before do
      allow_any_instance_of(Shopper).to receive(:reset_password_token) { "xxccx" }
      mail
    end

    it "renders email" do
      expect(mail.to).to eql([shopper.email])
    end

    it "delivers message" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end
end
