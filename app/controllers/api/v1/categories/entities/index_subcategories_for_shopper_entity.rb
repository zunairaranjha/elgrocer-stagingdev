# frozen_string_literal: true

module API
  module V1
    module Categories
      module Entities
        class IndexSubcategoriesForShopperEntity < API::BaseEntity
          expose :non_empty_categories, using: API::V1::Categories::Entities::ShowEntity, as: :categories, documentation: {type: 'show_category', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        
          def non_empty_categories
            result = []
            retailer_id = options[:retailer_id]
        
            object[:categories].each do |cat|
              if retailer_id.present?
                counter = Brand.joins(:retailers, :subcategories)
                  .select('count(distinct brands.id) as brand_count')
                  .where(retailers: { id: retailer_id }, categories: { id: cat.id} )
              else
                ### depreceated
                counter = Brand.connection.select_all("SELECT count(DISTINCT b.id) AS brand_count FROM brands as b
                          INNER JOIN products AS p ON p.brand_id = b.id
                          INNER JOIN shops AS s ON s.product_id = p.id
                          INNER JOIN retailers AS r ON r.id = s.retailer_id
                          INNER JOIN product_categories AS pc ON pc.product_id = p.id
                          INNER JOIN categories AS sc ON pc.category_id = sc.id
                          LEFT JOIN retailer_has_locations AS rhl ON rhl.retailer_id = r.id
                          WHERE
                            r.is_opened IS TRUE AND
                            r.is_active IS TRUE AND
                            rhl.retailer_id IS NULL AND
                            sc.id  = %{id};" % {id: cat.id, location_id: options[:location_id]})
              end
              result.push(cat) if counter[0]['brand_count'].to_i > 0
            end
            result
          end
        end        
      end
    end
  end
end