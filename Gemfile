source 'https://rubygems.org'
ruby "3.1.2"

# standard ror gems
gem 'rails', '7.0.2'
gem 'pg'#, '~> 0.11'
gem 'sass-rails' #, '~> 5.0'
gem 'uglifier' #, '>= 1.3.0'
gem 'coffee-rails' #, '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder' #, '~> 2.0'
gem 'sdoc', group: :doc
gem 'cancancan'
gem 'bootsnap'
gem 'psych'
gem "webpacker"
gem 'net-http'
# gem 'mime-types', [ '~> 2.6', '>= 2.6.1' ], require: 'mime/types/columnar'

# Manages application-specific business logic
# Implementation of the command pattern in Ruby
gem 'active_interaction'
gem 'virtus'

# pagination
gem 'kaminari'

#sms sender
# gem 'nexmo'

# elasticsearch gems
#gem 'elasticsearch-rails'
#gem 'elasticsearch-model', '~> 5'
#gem 'bonsai-elasticsearch-rails'

gem "algoliasearch-rails"

gem "searchjoy"
gem 'friendly_id' #, '~> 5.1.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+

gem "httpclient"

# phone number
gem 'phony_rails'

# identify_cahce - for caching associtaions
gem 'identity_cache'
gem 'cityhash'        # optional, for faster hashing (C-Ruby only)

# slack
gem 'slack-notifier'

# zero push
# gem 'zero_push'
# gem 'pushwoosh'
# gem 'gcm'
gem 'fcm'
gem "houston"
# Apple push notifications
gem 'apnotic'

# gem "rpush"
gem "adyen-ruby-api-library"
# rescue
gem 'resque', :require => "resque/server"
# gem 'resque-pool'

gem 'redis-rails'

# monitoring tools
gem 'newrelic_rpm'
gem 'airbrake'
gem 'scout_apm'

# active admin
gem 'formtastic'

# api builder
gem 'grape'#, "~> 1.2.5"
gem 'grape-entity'
gem 'rack-contrib'
gem 'grape-swagger'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'

# localization helpers
gem 'i18n_structure'

# models decorator
gem 'draper' #, '~> 1.3'

# admin panel
gem 'activeadmin' #, '~> 1.1.0'
gem 'active_skin'
gem "active_admin_import" #, '2.1.2'
gem 'activeadmin_addons'
gem 'active_admin_datetimepicker'

# puma
gem 'foreman'
gem 'puma'

# authorization
gem 'devise'

# scraping
gem "mechanize"

# api for the open product database
gem 'datakick'

# collection of all sorts of useful information for every country
gem 'countries', :require => 'countries/global'

# roo - sheets library
gem 'roo' #, '~> 2.1.0'
gem 'axlsx'

gem 'zip-zip'

# library integration of the money
gem 'money-rails'

# active record extensions
# gem "paperclip" #, "~> 4.3"
gem "kt-paperclip"
gem 'aws-sdk-s3' #, '~> 1.6' # file upload to s3

gem 'time_of_day_attr'

gem 'iconv'

gem 'rgeo' #, '0.5.3'
gem 'activerecord-postgis-adapter'
gem 'geocoder'
gem 'nokogiri'

gem 'resque-scheduler'
gem 'rack-cors', :require => 'rack/cors'

gem 'sitemap_generator'
gem 'doorkeeper'#, '5.0.3'

gem 'rdkafka', '0.11.0'

#Faraday
# gem 'faraday'

#HTTP/REST API client library
gem 'faraday'
gem 'faraday-httpclient'


# logs bugs in sentry
gem "sentry-ruby"
gem "sentry-rails"

group :production do
  gem 'rails_12factor'
  gem 'derailed'
end

# Database views gem
gem "scenic"

group :development do
  gem 'letter_opener'
  gem 'web-console'
  gem 'derailed_benchmarks'
  gem 'stackprof'
  gem 'rubocop'
end

group :development, :test do
  gem 'resque-web', require: 'resque_web'
  gem "factory_bot_rails"
  # gem 'pry-rails'
  # gem 'pry-doc'
  # gem 'pry-byebug'
  gem 'delorean'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'spring'
  gem 'capybara'
  gem 'faker'
  gem 'guard-rspec'
  gem 'dotenv-rails'
  gem 'bullet'
end

group :test do
  gem 'simplecov', require: false, group: :test
  gem "database_cleaner"
  gem 'rspec-its'
  #gem 'elasticsearch-extensions'
  gem 'shoulda-matchers', '~> 3.0'
  # gem "webmock"
end
