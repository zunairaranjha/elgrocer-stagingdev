# frozen_string_literal: true

module API
  module V1
    module Orders
      module Entities
        class ShowPositionEntity < API::BaseEntity
          root 'order_positions', 'order_position'

          def self.entity_name
            'show_order_positions'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :order_id, documentation: { type: 'Integer', desc: 'ID or order' }, format_with: :integer
          expose :product_barcode, documentation: { type: 'String', desc: "Order's product barcode" }, format_with: :string
          expose :product_brand_id, documentation: { type: 'Integer', desc: "Order's product brand id" }, format_with: :integer
          expose :product_brand_name, documentation: { type: 'String', desc: "Order's product brand name" }, format_with: :string
          expose :product_name, documentation: { type: 'String', desc: "Order's product name" }, format_with: :string
          expose :product_description, documentation: { type: 'String', desc: "Order's product description" }, format_with: :string
          expose :product_shelf_life, documentation: { type: 'String', desc: "Order's product shelf life" }, format_with: :string
          expose :product_size_unit, documentation: { type: 'String', desc: "Order's product size unit" }, format_with: :string
          expose :product_country_alpha2, documentation: { type: 'String', desc: "Order's product country_alpha2" }, format_with: :string
          # expose :product_category_id, documentation: {type: 'Integer', desc: "Order's product category id"}, format_with: :integer
          expose :product_category_name, documentation: { type: 'String', desc: "Order's product category name" }, format_with: :string
          expose :product_subcategory_id, documentation: { type: 'Integer', desc: "Order's product subcategory ID" }, format_with: :integer
          expose :product_subcategory_name, documentation: { type: 'String', desc: "Order's product subcategory name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :amount, documentation: { type: 'Integer', desc: 'Amount of requested goods' }, format_with: :integer
          expose :product_id, documentation: { type: 'Integer', desc: "Order's product id" }, format_with: :integer

          expose :shop_price_cents, documentation: { type: 'integer', desc: "Order's product price currency" }, format_with: :integer
          expose :shop_price_dollars, documentation: { type: 'integer', desc: "Order's product price currency" }, format_with: :integer
          expose :shop_price_currency, documentation: { type: 'String', desc: "Order's product price currency" }, format_with: :string
          expose :shop_id, documentation: { type: 'Integer', desc: 'Shop relation id' }, format_with: :integer

          expose :was_in_shop, documentation: { type: 'Bool', desc: 'Describes if item was initiali in shop' }, format_with: :bool
          expose :is_promotional, as: :is_p, documentation: { type: 'Bool', desc: 'Describes if item is is_promotional in shop' }, format_with: :bool
          # expose :order_substitutions, with: API::V1::OrderSubstitutions::Entities::ShowEntity, documentation: { is_array: true }
          # expose :substituting_product, documentation: { is_array: true }

          expose :order_substitutions, documentation: { type: 'show_product', is_array: true } do |result, options|
            API::V1::Orders::Entities::ShowSubstitutionProduct.represent order_substitutions, options.merge(retailer_id: object.order.retailer_id)
          end
          expose :substitute_for, documentation: { type: 'String', desc: 'Substitute for' }, format_with: :string, :if => Proc.new { |result| options[:retailer] }

          private

          def product_id
            object.product_id || object.product_proposal.product_id
          end

          def shop_id
            object.try(:shop_id)
          end

          # def is_promotional
          #   Shop.unscoped.where(id: object.shop_id).first.is_promotional rescue false
          # end

          def product_brand_id
            object.try(:brand_id) || object.product.try(:brand_id) || object.product_proposal.try(:brand_id)
          end

          def product_category_id
            # object.product.try { |p| p.categories.first.try(:id) }
            object.try(:category_id) || ProductCategory.find_by(product_id: object.product_id).try { |pc| pc.category.parent_id }
          end

          def product_subcategory_id
            # object.product.try { |p| p.subcategories.first.try(:id) }
            object.try(:subcategory_id) || ProductCategory.find_by(product_id: object.product_id).try(:category_id)
          end

          def order_substitutions
            # Rails.cache.fetch("#{object.order_id}:#{object.product_id}/order_substitutions", expires_in: 1.hours) do
            # object.order.order_substitutions.where(product_id: object.product_id).map {|s| s.substituting_product } if object.order.status_id == 6
            object.order.order_substitutions.select { |os| os.product_id == object.product_id }.map { |s| s.substituting_product } if object.order.status_id == 6
            # end
          end

          def substitute_for
            object.order.order_substitutions.select { |os| os.substituting_product_id == object.product_id and os.is_selected == true }.first&.substitute_detail.try(:[], 'product_name')
          end

          def image_url
            object.product.try(:photo_url) || object.product_proposal.image.try(:photo_url) || 'https://api.elgrocer.com/images/medium/missing.png'
            # if object.product
            #   object.product.photo ? object.product.photo.url(:medium) : nil
            # else
            #   nil
            # end
          end

          def full_image_url
            object.product.try(:photo_url) || object.product_proposal.image.try(:photo_url) || 'https://api.elgrocer.com/images/medium/missing.png'
            # if object.product
            #   object.product.photo ? object.product.photo_url : nil
            # else
            #   nil
            # end
          end

        end
      end
    end
  end
end
