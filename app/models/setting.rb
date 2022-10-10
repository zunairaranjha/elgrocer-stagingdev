class Setting < ActiveRecord::Base
  # attr_accessor :es_search_fields,:es_min_match

  def es_search_fields
    search_fields = Redis.current.smembers :es_search_fields
    search_fields = ["name*^3", "category_name*", "subcategory_name*^2", "brand_name*", "description*", "size_unit*"] if search_fields.blank?
    search_fields.join(', ')
  end

  def es_min_match
    Redis.current.get :es_min_match
  end

  def es_search_fields=(val)
    Redis.current.del :es_search_fields
    val = "name*^3, category_name*, subcategory_name*^2, brand_name*, description*, size_unit*" if val.blank?
    Redis.current.sadd :es_search_fields, val.split(",").map(&:strip)
  end

  def es_min_match=(val)
    Redis.current.set :es_min_match, val
  end

end
