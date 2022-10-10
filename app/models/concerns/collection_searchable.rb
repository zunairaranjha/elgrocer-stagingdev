module CollectionSearchable
  extend ActiveSupport::Concern

  included do
    include Searchable

    def self.get_retailers_ids(retailer_id = nil)
      retailer_where = {is_opened: true, is_active: true}

      retailer_where[:id] = retailer_id if retailer_id
      today = Time.now.wday + 1
      retailers_ids = Retailer.joins(:retailer_opening_hours).where(:retailers => retailer_where, :retailer_opening_hours => {:day => today}).where("retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close  > #{Time.now.seconds_since_midnight}" ).pluck(:id)
      retailers_ids
    end

    def self.get_retailers_query(retailer_id)
      { terms: {"retailer_id" => get_retailers_ids(retailer_id)}}
    end

    def self.prepare_query(for_retailer, input, retailer_id, min_match = "70", search_operator = "and")
      search_fields = (Redis.current.smembers :es_search_fields)
      search_fields = ["name*^3", "category_name*", "subcategory_name*^2", "brand_name*", "description*", "size_unit*"] if search_fields.blank?
      query = {
        bool: {
          must: [
            { multi_match: {
                query: input,
                slop: 50,
                type: "most_fields",
                minimum_should_match: "#{(Redis.current.get :es_min_match) || min_match}%",
                fields: search_fields,
                # fuzziness: "0",
                # analyzer: "snowball",
                operator: search_operator
              }
            }
          ],
          must_not: [{term: {image_url: "missing.png"}}, {term: {is_published: "false"}}, {term: {is_available: "false"}}]
        }
      }

      unless for_retailer
        # retailer_query = get_retailers_query(retailer_id)
        # query[:bool][:must].push(retailer_query) if retailer_id
        query[:bool][:must].push({term: {retailer_id: retailer_id}}) if retailer_id
      end
      query
    end

    def self.prepare_query_for_products(input, retailer_id, brand_id, category_id, min_match = "70", search_operator = "and")
      query = { bool: { must: [ ], must_not: [{term: {image_url: "missing.png"}}, {term: {is_published: "false"}}, {term: {is_available: "false"}}] } }

      unless input.blank?
        query = self.prepare_query(false, input, nil, min_match, search_operator)
      end

      if retailer_id
        query[:bool][:must].push({ term: { retailer_id: retailer_id } })
      end

      if brand_id
        query[:bool][:must].push({term: {'brand.id':  brand_id}})
      end

      unless category_id && category_id.compact.blank?
        query[:bool][:must].push({terms: {'categories.children.id': category_id}})
      end
      query
    end

    def self.search_name(for_retailer, input, retailer_id = nil)
      query = prepare_query(for_retailer, input, retailer_id)
      if for_retailer
        search(query)
      else
        search(query, {sort: ['_score', { product_rank: "desc" }]})
      end
    end

    def self.search_products(input, retailer_id, brand_id, category_id, limit, offset)
      query = prepare_query_for_products(input, retailer_id, brand_id, category_id)
      ##### Handle forgery
      if limit.present?
        limit = limit > 100 ? 100 : limit
      end
      if offset.present?
        offset = offset > 500 ? 500 : offset
      end
      ### Handle forgry
      search(query, {size: limit || 10, from: offset || 0, sort: ['_score', { product_rank: "desc" }] })
    end
  end
end

