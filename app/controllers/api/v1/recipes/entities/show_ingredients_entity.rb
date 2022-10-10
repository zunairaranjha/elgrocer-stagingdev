module API
  module V1
    module Recipes
      module Entities
        class ShowIngredientsEntity < API::BaseEntity
          def self.entity_name
            'show_recipe_ingredients'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the ingredient" }, format_with: :integer
          expose :product_id, documentation: { type: 'Integer', desc: "Product ID" }, format_with: :integer
          expose :product_name, documentation: { type: 'String', desc: "Name of ingredient" }, as: :name, format_with: :string
          expose :brand_id, documentation: { type: 'Integer', desc: "Brand Id" }, format_with: :integer
          expose :subcategory_id, documentation: { type: 'Integer', desc: "SubCategory Id" }, format_with: :integer
          expose :price, documentation: { type: 'Float', desc: 'Price of product in current retailer' }, format_with: :float
          expose :is_available, documentation: { type: 'Boolean', desc: 'Is product available?' }, format_with: :bool
          expose :is_published, documentation: { type: 'Boolean', desc: 'Is product published?' }, format_with: :bool
          expose :is_promotional, as: :is_p, documentation: { type: 'Boolean', desc: 'Is product promotional?' }, format_with: :bool
          expose :qty, documentation: { type: 'Float', desc: "Quantity" }, format_with: :float
          expose :qty_unit, documentation: { type: 'String', desc: "Units of quantity" }, format_with: :string
          expose :size_unit, documentation: { type: 'String', desc: "Products size unit" }, format_with: :string
          expose :recipe_id, documentation: { type: 'Integer', desc: "Recipe Id" }, format_with: :integer
          expose :image_url, documentation: { type: 'String', desc: "url of image" }, format_with: :string
          expose :brand, using: API::V1::Brands::Entities::ShowEntity, documentation: {type: 'show_brand', is_array: true }
          expose :categories, using: API::V1::Products::Entities::ShowNameEntity, documentation: {type: 'name_entity', is_array: true }
          expose :subcategories, using: API::V1::Products::Entities::ShowNameEntity, documentation: {type: 'name_entity', is_array: true }
        
          def image_url
            object.product.try(:photo_url)
          end
        
          def brand
            object.product.try(:brand)
          end
        
          def categories
            object.product.try(:categories)
          end
        
          def subcategories
            object.product.try(:subcategories)
          end
        
          def product_name
            object.product.try(:name)
          end
        
          def brand_id
            object.product.try(:brand_id)
          end
        
          def subcategory_id
            object.product.subcategories.first.id rescue nil
          end
        
          def size_unit
            object.product.try(:size_unit)
          end
        
          def price
            (object.try(:price_dollars).to_f + (object.try(:price_cents).to_f)/100).round(2)
            # record = Shop.find_by(product_id: object.id, retailer_id: options[:retailer_id])
            #record = shop
            #result = nil
            #if record
            #  result = (record.price_dollars.to_f + (record.price_cents.to_f)/100).round(2)
            #end
            #result
          end
          
          #def shop
          #  # @shop ||= object.product.shops.where(retailer_id: retailer.id)
          #  @shop ||= Shop.find_by(product_id: object.product.try(:id), retailer_id: retailer.id) if retailer
          #end
        
          def is_available
            object.try(:is_available)
          end
        
          def is_published
            object.try(:is_published)
          end
        
          def is_promotional
            object.try(:is_promotional)
          end
        
          #def retailer
          #  @retailer ||= Retailer.find(options[:retailer_id]) if options[:retailer_id]
          #end
        
        end                
      end
    end
  end
end