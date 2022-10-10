class ForceCreatedAtToNow < ActiveRecord::Migration
    def up
        change_column :products, :created_at, :datetime, :default => Time.now
        change_column :products, :updated_at, :datetime, :default => Time.now

        change_column :categories, :created_at, :datetime, :default => Time.now
        change_column :categories, :updated_at, :datetime,:default => Time.now

        change_column :brands, :created_at, :datetime,:default => Time.now
        change_column :brands, :updated_at, :datetime,:default => Time.now

        change_column :retailers, :created_at, :datetime,:default => Time.now
        change_column :retailers, :updated_at, :datetime,:default => Time.now

        change_column :product_categories, :created_at, :datetime,:default => Time.now
        change_column :product_categories, :updated_at, :datetime,:default => Time.now

        change_column :shops, :created_at, :datetime,:default => Time.now
        change_column :shops, :updated_at, :datetime,:default => Time.now
    end
    def down
        change_column :products, :created_at, :default => nil
        change_column :products, :updated_at, :default => nil

        change_column :categories, :created_at, :default => nil
        change_column :categories, :updated_at, :default => nil

        change_column :brands, :created_at, :default => nil
        change_column :brands, :updated_at, :default => nil

        change_column :retailers, :created_at, :default => nil
        change_column :retailers, :updated_at, :default => nil

        change_column :product_categories, :created_at, :default => nil
        change_column :product_categories, :updated_at, :default => nil

        change_column :shops, :created_at, :default => nil
        change_column :shops, :updated_at, :default => nil
    end
end
