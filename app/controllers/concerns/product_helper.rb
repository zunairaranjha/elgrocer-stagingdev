module Concerns
  module ProductHelper
    extend Grape::API::Helpers

    def retailer_id
      @retailer_id ||= params[:retailer_id][/\p{L}/] ? Retailer.select(:id, :with_stock_level).find_by_slug(params[:retailer_id]) : Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
    end

    def subcategory_id
      @subcategory_id ||= params[:subcategory_id][/\p{L}/] ? Category.select(:id).find_by_slug(params[:subcategory_id]) : Category.select(:id).find_by_id(params[:subcategory_id])
    end

    def subcategories_ids
      @child_ids ||= Category.joins(:parent).where(params[:category_id][/\p{L}/] ? "parents_categories.slug = '#{params[:category_id]}'" : "parents_categories.id = #{params[:category_id]}").select(:id)
    end

    def brand_id
      @brand_id ||= params[:brand_id][/\p{L}/] ? Brand.select(:id).find_by_slug(params[:brand_id]) : Brand.select(:id).find_by_id(params[:brand_id])
    end

    def attach_subcategory(products)
      products.where(product_categories: { category_id: subcategory_id })
    end

    def attach_category(products)
      products.where(product_categories: { category_id: subcategories_ids })
    end
  end
end
