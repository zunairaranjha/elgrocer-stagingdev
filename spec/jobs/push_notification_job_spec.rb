require "rails_helper"

describe PushNotificationJob do

  let(:params) do
    {
        'message': 'An order has been approved!',
        'order_id': 1,
        'message_type': 1,
        'retailer_id': 1
    }
  end
  let(:registration_id) { "wsadsafghwwww" }

  describe "perform" do
    context "google" do
      it "push google" do
        expect(GoogleMessaging).to receive(:push).with(registration_id, params, nil, nil, nil, false)

        subject.perform(registration_id, params, 0)
      end
    end

    context "google" do
      it "push osx" do
        expect(AppleNotifications).to receive(:push).with(registration_id, params, params[:message])

        subject.perform(registration_id, params, 1)
      end
    end
  end
end
