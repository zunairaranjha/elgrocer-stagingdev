# frozen_string_literal: true

module API
  module V2
    module Categories
      module Entities
        class ShowEntity < API::BaseEntity

          def self.entity_name
            'show_category'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the category' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Category name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Category description' }, format_with: :string
          expose :message, documentation: { type: 'String', desc: 'Message to show on category' }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: 'SEO Data' }, format_with: :string, if: Proc.new { |obj| options[:web] }
          # expose :priority, documentation: { type: 'Integer', desc: "priority" }, format_with: :integer
          # expose :is_show_brand, documentation: {type: "Boolean", desc: 'Is Show brands in Apps'}, format_with: :bool
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :logo_url, as: :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :logo_url, as: :logo1_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :show_brand, as: :is_show_brand, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :is_food, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :pg_18, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool

          def show_brand
            object.current_tags.include? Category.tags[:is_show_brand]
          end

          def is_food
            object.current_tags.include? Category.tags[:is_food]
          end

          def pg_18
            object.current_tags.include? Category.tags[:pg_18]
          end

          # private

          # def image_url
          #   object.logo.present? ? object.logo.url(:medium) : "http://#{options[:env]['HTTP_HOST']}#{object.logo.url(:medium)}"
          # end

          # def logo1_url
          #   object.logo1.present? ? object.logo1.url(:medium) : "http://#{options[:env]['HTTP_HOST']}#{object.logo1.url(:medium)}"
          # end
        end
      end
    end
  end
end
