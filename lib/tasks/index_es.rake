namespace :index_es do
  desc 'Creates product index'
  task create_product_index: :environment do
    Product.__elasticsearch__.create_index! force: true
    Product.__elasticsearch__.import
  end

  desc 'Creates retailer index'
  task create_retailer_index: :environment do
    Retailer.__elasticsearch__.create_index! force: true
    Retailer.__elasticsearch__.import
  end

  desc 'Creates category index'
  task create_category_index: :environment do
    Category.__elasticsearch__.create_index! force: true
    Category.__elasticsearch__.import
  end

  desc 'Creates shop index'
  task create_shop_index: :environment do
    Shop.__elasticsearch__.create_index! force: true
    Shop.__elasticsearch__.import
  end

  desc 'Deletes product index'
  task delete_product_index: :environment do
    Product.__elasticsearch__.delete_index!
  end

  desc 'Creates all indexes'
  task create_indexes: :environment do
    t = Benchmark.realtime do
      Shop.__elasticsearch__.create_index! force: true
      Shop.__elasticsearch__.import
    end
    puts "Imported shops in #{t}s"
    t = Benchmark.realtime do
      Product.__elasticsearch__.create_index! force: true
      Product.__elasticsearch__.import
    end
    puts "Imported products in #{t}s"
    t = Benchmark.realtime do
      Category.__elasticsearch__.create_index! force: true
      Category.__elasticsearch__.import
    end
    puts "Imported categories in #{t}s"
    t = Benchmark.realtime do
      Retailer.__elasticsearch__.create_index! force: true
      Retailer.__elasticsearch__.import
    end
    puts "Imported retailers in #{t}s"
  end

  desc 'Create product index from resque'
  task create_product_index_on_resque: :environment do
    Product.__elasticsearch__.create_index! force: true
    Product.find_each do |product|
      Resque.enqueue(Indexer, :create, product.class.name, product.id)
    end
  end

  desc 'Create shop index from resque'
  task create_shop_index_on_resque: :environment do
    Shop.__elasticsearch__.create_index! force: true
    Shop.find_each do |shop|
      Resque.enqueue(Indexer, :create, shop.class.name, shop.id)
    end
  end

  desc 'Create retailer index from resque'
  task create_retailer_index_on_resque: :environment do
    Retailer.__elasticsearch__.create_index! force: true
    Retailer.find_each do |retailer|
      Resque.enqueue(Indexer, :create, retailer.class.name, retailer.id)
    end
  end

  desc 'Create category index from resque'
  task create_category_index_on_resque: :environment do
    Product.__elasticsearch__.create_index! force: true
    Category.find_each do |category|
      Resque.enqueue(Indexer, :create, category.class.name, category.id)
    end
  end
end
