module AlgoliaProductIndexing
  extend ActiveSupport::Concern

  included do
    include AlgoliaSearch

    after_touch :index!

    algoliasearch do
      attribute :id, :name, :name_ar, :barcode, :photo_url, :size_unit
      attribute :is_p do
        self.is_promotional ? 1 : 0
      end
      attribute :brand do
        brands
      end
      # attribute :product_rank do (shops.max_by{|k| k[:product_rank]}.try(:product_rank).to_f * 100).to_i end
      attribute :product_rank do
        sale_rank
      end
      # attribute :is_promotional do self.is_promotional? ? 1 : 0 end
      attribute :is_sponsored do
        0
        # if Product.sponsored_ids.include? "#{id}"
        #   keywords = []
        #   BrandSearchKeyword.where(" ? between date(start_date) and date(end_date) and product_ids ~ '\\y?\\y'", Time.now.to_date, id).pluck(:keywords).each do |keyword|
        #     keywords.push(keyword.split(','))
        #   end
        #   product_keywords = []
        #   # Product.where(id: id).pluck(:search_keywords).each do |keyword|
        #   #   product_keywords.push(keyword.split(','))
        #   # end
        #   @search_keywords = (product_keywords.flatten | keywords.flatten).join(',')
        #   Product.where(id: id).update_all(search_keywords: @search_keywords)
        #   1
        # else
        #   0
        # end
      end
      attribute :category_rank do
        category_parent.try(:priority)
      end
      attribute :subcategory_rank do
        subcategories.first.try(:sale_rank)
      end
      attribute :sponsored_keywords do
        '' #@search_keywords
      end
      attribute :shops do
        shop_join_retailers.map do |shop|
          {
            # id: shop.id,
            retailer_id: shop.retailer_id,
            retailer_slug: shop.slug,
            # rank: (shop.product_rank.to_f * 100).to_i,
            # is_published: shop.is_published,
            # is_available: shop.is_available,
            price: shop.full_price.to_f.round(2),
            price_currency: shop.price_currency,
            is_p: shop.is_promotional? ? 1 : 0,
            promotion_only: shop.promotion_only? ? 1 : 0,
            available_quantity: shop.with_stock_level ? shop.available_for_sale.to_i : -1
          }
        end
      end
      attribute :promotional_shops do
        algolia_shop_promotions.map do |promo_shop|
          {
            retailer_id: promo_shop.retailer_id,
            price: promo_shop.price,
            standard_price: promo_shop.standard_price,
            price_currency: promo_shop.price_currency,
            start_time: promo_shop.start_time,
            end_time: promo_shop.end_time,
            product_limit: promo_shop.product_limit
          }
        end
      end
      attribute :categories do
        categories.map do |cat|
          {
            id: cat.id,
            name: cat.name,
            name_ar: cat.name_ar,
            slug: cat.slug,
            image_url: cat.photo_url,
            message: cat.message,
            message_ar: cat.message_ar,
            # is_food: cat.is_food
            is_show_brand: cat.current_tags.include?(Category.tags[:is_show_brand]),
            is_food: cat.current_tags.include?(Category.tags[:is_food]),
            pg_18: cat.current_tags.include?(Category.tags[:pg_18])
          }
        end
      end
      attribute :subcategories do
        subcategories.map do |child|
          {
            id: child.id,
            name: child.name,
            name_ar: child.name_ar,
            slug: child.slug,
            image_url: child.photo_url,
            message: child.message,
            message_ar: child.message_ar,
            is_show_brand: child.current_tags.include?(Category.tags[:is_show_brand]),
            is_food: child.current_tags.include?(Category.tags[:is_food]),
            pg_18: child.current_tags.include?(Category.tags[:pg_18])
          }
        end
      end
    end
  end
end