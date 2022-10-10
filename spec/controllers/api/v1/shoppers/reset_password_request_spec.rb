require "rails_helper"

describe API::V1::Shoppers::ResetPasswordRequest, type: :request do
  include ActiveJob::TestHelper

  let!(:shopper) { create(:shopper, phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0'), email: "example2@dubai.com") }
  let(:token) { { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true } }

  it "enques email" do
    expect {
      post '/api/v1/shoppers/reset_password_request', params: { email: shopper.email }, headers: token
    }.to change { enqueued_jobs.size }.by(1)
  end
end
