namespace :test_orders do
  desc 'It delete test orders'
  task delete_orders: :environment do
    retailer_group_ids = ENV['retailer_group_id'] || 1
    Order.joins(:retailer).where(retailers: { retailer_group_id: retailer_group_ids.to_s.split(',') }).destroy_all
  end
end
