elgrocer main app
============================

Description
----------------------------

This app is the core app of entire elgrocer system. It consist of 2 main parts:

1. admin panel which allows elgrocer manager to monitor and menage entire system
2. apis - both Buyer and Seller apis build upon Grape gem

Dependencies
----------------------------

To run this app you have to have installed following dependencies:

1. postgresql 9.4 + postgis
2. libgeos-dev + libproj-dev for rgeo
3. ruby in version 2.2.2
4. elasticsearch in version < 2.0
5. imagemagick for paperclip

How to setup and run the app
----------------------------

1. clone the app from github
2. copy ./config/database-default.yml to ./config/database.yml and setup it accordingly to you database configuration. (to create database you can use ```rake db:create```)
3. run migrations - in terminal: ```rake db:migrate```
4. to run the app write: ```rails s``` in terminal
5. app will be available on ```localhost:3000```

How to run tests
----------------------------

App uses rspec as a test engine. To run tests just write in terminal:

    bundle exec rspec spec

PostGIS
----------------------------

change adapter in database.yml
- adapter: postgis
and add
- schema_search_path: public,postgis
see database_default.yml

This rake task adds the PostGIS extension to your existing database.

### rake db:gis:setup

Deployment
----------------------------

App is deployed on heroku using continous delivery (with help of codeship). It means that whatever you push to master or staging branch will go to production or staging environment respectively (of course when all tests pass).

Tasks
----------------------------

### rake scrape:supermart

scrapes supermart page and adds products to the database

Elastic Search
----------------------------

Elastic Search provides a great way to search through lots of data. For more detail check: https://www.elastic.co/

On heroku we use Bonsai Elasticsearch

Reindexing from a local machine
(DO IT ONLY IF BONSAI BROKE AND ELASTICSEARCH IS NOT RESPONDING AFTER BONSAI RESTART OR YOU CHANGED as_indexed_json METHOD IN MODEL!)

### heroku run rake index_se:create_<model>_index

Just replace the tag with desired model's name.

Background jobs - Resque
----------------------------

For background jobs ElGrocer-api is using a gem called resque. Because the api is hosted on Heroku this was the best option. Official heroku statement:

"We recommend not using delayed job for most applications due to the extra load generated on the database. Instead we recommend a Redis based queuing library."

We're using two addons on Heroku for this:

- Redis To Go
- Redis Cloud

Go ahead and read about them!

For background jobs a worker is require, so we need at least one. Heroku is well prepared for resque gem usage because it has a specific worker dyno for it.
