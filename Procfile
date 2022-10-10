web: bin/start-pgbouncer bundle exec puma -C config/puma.rb
resque: env TERM_CHILD=3 QUEUE='default, order, mailers, order_allocation, indexer_queue, shop_products_rule, welcome_emails_queue, abandon_basket_emails_queue, reminder_emails_queue' COUNT='3' bundle exec rake resque:workers
scheduler: env bundle exec rake resque:scheduler