#require "codeclimate-test-reporter"
require 'simplecov'
SimpleCov.start
#CodeClimate::TestReporter.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'shoulda/matchers'
require 'devise'
require 'capybara/rails'
require 'database_cleaner'
require 'factory_bot'
Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| require f }
include GeocoderStub

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Delorean
  config.include FactoryBot::Syntax::Methods
  config.include Requests::JsonHelpers, type: :request

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    DatabaseCleaner.clean
  end

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
