# frozen_string_literal: true

module API
  module V1
    module PromotionCodes
      module Entities
        class PromoCodesListEntity < API::BaseEntity
          expose :id, documentation: { type: 'Integer', desc: 'ID of the promo code' }, format_with: :integer
          expose :code, documentation: { type: 'String', desc: 'Code of the Promo Code' }, format_with: :string
          expose :percentage_off, documentation: { type: 'Float', desc: '%age off' }, format_with: :integer
          expose :max_cap_value, documentation: { type: 'Float', desc: 'maximum discount' }, format_with: :float
          expose :name, documentation: { type: 'String', desc: 'name of the code' }, format_with: :string
          expose :title, documentation: { type: 'String', desc: 'title of code' }, format_with: :string
          expose :description, as: :detail, documentation: { type: 'String', desc: 'Created_at' }, format_with: :string
          expose :all_brands, documentation: { type: 'Boolean', desc: 'Created_at' }, format_with: :bool
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Created_at' }, format_with: :float
          expose :creation_date, documentation: { type: 'dateTime', desc: 'Created_at' }, format_with: :integer
          expose :expire_date, documentation: { type: 'dateTime', desc: 'Created_at' }, format_with: :integer
          expose :photo_url, documentation: { type: 'String', desc: 'Photo Url' }, format_with: :string
          expose :brands, using: API::V1::PromotionCodes::Entities::PromoCodeBrandsEntity, documentation: { type: 'show_promotion_code_brands' }

          def max_cap_value
            object.value_cents / 100.to_f.round(2)
          end

          def creation_date
            (object.start_date.to_time.utc.to_f * 1000).floor
          end

          def expire_date
            (object.end_date.to_time.utc.to_f * 1000).floor
          end

          def name
            object.name.blank? ? options[:retailer].name : object.name
          end

          def photo_url
            object.photo_url || 'https://api.elgrocer.com/favicon-1.png'
          end

        end
      end
    end
  end
end
