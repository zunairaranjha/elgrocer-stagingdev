# frozen_string_literal: true

module API
  module V2
    module RetailerReports
      module Entities
        class IndexEntity < API::BaseEntity
          root 'retailer_reports', 'retailer_report'
        
          #def self.entity_name
          #  'show_retailer'
          #end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the report' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Report name' }, format_with: :string
          expose :export_total, documentation: { type: 'Integer', desc: 'Shop average rating' }, format_with: :float
          expose :file1_url, documentation: { type: 'String', desc: "An URL directing to a orders csv." }, format_with: :string
          expose :file2_url, documentation: { type: 'String', desc: "An URL directing to a orders positions csv." }, format_with: :string
          expose :from_date, documentation: { type: 'String', desc: 'From Date' }, format_with: :string
          expose :to_date, documentation: { type: 'String', desc: 'To Date' }, format_with: :string
        
          def file1_url
            object.file1.url
          end
        
          def file2_url
            object.file2.url
          end
          
        end                
      end
    end
  end
end