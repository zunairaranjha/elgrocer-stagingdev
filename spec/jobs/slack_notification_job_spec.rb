require "rails_helper"

describe SlackNotificationJob do
  let!(:retailer) do
    FactoryBot.create(:retailer)
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:order1) do
    FactoryBot.create(:order, {
      shopper_id: shopper.id,
      retailer_company_name: retailer.company_name,
      retailer_id: retailer.id,
      shopper_name: shopper.name
    })
  end

  describe "perform" do
    it "push osx" do
      expect_any_instance_of(Slack::SlackNotification).to receive(:send_new_order_notification)
                                                            .with(order1.id)

      subject.perform(order1.id)
    end
  end
end
