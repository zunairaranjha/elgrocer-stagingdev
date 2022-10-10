require "virtus"
require "open-uri"

module Scraper
  class Model
    include Virtus.model

    attribute :url, String
    attribute :name, String
    attribute :price, String
    attribute :brand, String
    attribute :weights, Array
    attribute :categories, Array
    attribute :img_url, String
    attribute :description, String

    def create_product(force=false)
      existing = Product.where(:name => name).first
      if existing
        if force
          existing.destroy
        else
          return existing
        end
      end
      product = Product.new
      product.subcategories = create_categories
      product.brand = create_brand
      if img_url
        product.photo = open(img_url) rescue nil
      end
      product.name = name
      product.description = description
      product.save
      product
    end

    private
      # it creates all categories but returns only last
      def create_categories
        ret = []
        categories.each do |category_row|
          parent_category_id = nil
          category = nil

          category_row.each do |name|
            category = Category.where(:name => name, :parent_id => parent_category_id).first
            category ||= Category.create(:name => name, :parent_id => parent_category_id)
            parent_category_id = category.id
          end
          ret.push category
        end
        ret
      end

      def create_brand
        b = Brand.where(:name => brand).first
        b ||= Brand.create(:name => brand)
      end
  end
end