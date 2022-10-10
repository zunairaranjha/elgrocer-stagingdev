class PushwooshEmailTagingJob < ActiveJob::Base
  queue_as :default

  def perform(shopper_id)
    shopper = Shopper.find_by(id: shopper_id)
    if shopper
      app_id = ENV['PUSHWOOSH_APPLICATION']
      access_key = ENV['PUSHWOOSH_API_ACCESS']
      request_url = URI.parse(ENV['PUSHWOOSH_BASE_URL'])
      client = HTTPClient.new
      body = { request: {
          auth: access_key,
          email: shopper.email,
          application: app_id,
          tags: { Email: shopper.email }}
      }.to_json
      response = client.post request_url + '/json/1.3/setEmailTags', body
      Analytic.add_activity("Shopper Email Tag", shopper, detail: response.body)
    end
  end
end