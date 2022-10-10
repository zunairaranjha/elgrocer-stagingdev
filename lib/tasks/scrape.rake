require Rails.root.join("lib", "scraper.rb")


namespace :scrape do
  desc "Scrapes supermart show"
  task supermart: :environment do
    Scraper::Supermart.new.scrape! do |model|
      model.create_product
      print "created: #{model.name}\n"
    end
  end

end