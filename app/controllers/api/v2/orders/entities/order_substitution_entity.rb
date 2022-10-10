# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class OrderSubstitutionEntity < API::BaseEntity

          expose :substituting_product, merge: true, unless: Proc.new { |g| g.product_proposal_id.present? }, documentation: { type: 'show_product', is_array: true } do |result, options|
            API::V2::Orders::Entities::ShowSubstitutionProduct.represent substituting_product, options.merge(shop_promotion: promotion)
          end

          # expose :order_logs, using: API::V2::Analytics::Entities::ShowEntity, documentation: { type: 'show_analytic', desc: 'Order loging', is_array: true }, :if => Proc.new { |order| options[:retailer] }
          expose :substituting_product, if: Proc.new { |g| g.product_proposal_id.present? }, merge: true, documentation: { type: 'show_product', is_array: true } do |result, options|
            API::V1::Orders::Entities::ShowProductProposal.represent substituting_product, options.merge(shop_promotion: promotion)
          end

          private

          def promotion
            object.shop_promotion
          end

          def substituting_product
            object.product_proposal_id.to_i.positive? ? object.product_proposal : object.substituting_product
          end

        end
      end
    end
  end
end
