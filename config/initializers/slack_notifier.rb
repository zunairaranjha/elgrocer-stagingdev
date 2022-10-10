ENV["SLACK_HOOK"] ||= "http://localhost:3000"

Rails.application.config.slack_hook = ENV["SLACK_HOOK"]