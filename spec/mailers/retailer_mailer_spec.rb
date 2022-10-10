require "rails_helper"

describe RetailerMailer do
  describe "#password_reset" do
    let!(:retailer) { create(:retailer) }
    let(:mail) { RetailerMailer.password_reset(retailer.id).deliver_now }

    before do
      allow_any_instance_of(Retailer).to receive(:reset_password_token) { "xxccx" }
      mail
    end

    it "renders email" do
      expect(mail.to).to eql([retailer.email])
    end

    it "delivers message" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end
end
