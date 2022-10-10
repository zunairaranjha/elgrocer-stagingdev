module API
  module V1
    module Webhooks
      module Entities
        class EmployeeDetail < API::BaseEntity

          def self.entity_name
            'employee_detail'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of Employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User Name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of Employee' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Retailer ID' }, format_with: :integer
          expose :retailer_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :activity_status, documentation: { type: 'String', desc: 'Current Activity Status' }, format_with: :string
          expose :roles, documentation: { type: 'String', desc: 'Roles of employee' }, format_with: :string
          expose :order, using: API::V1::Webhooks::Entities::OrderDetailEntity, documentation: { type: 'order_detail', is_array: true }
          expose :retailer, using: API::V1::Webhooks::Entities::RetailerDetailEntity, documentation: { type: 'retailer_detail', is_array: true }

          private

          def retailer
            @retailer = options[:retailer_id] ? Retailer.find_by_id(options[:retailer_id]) : employee_retailer
          end

          def employee_retailer
            @employee_retailer ||= object.retailer
          end

          def retailer_name
            employee_retailer&.company_name
          end

          def roles
            EmployeeRole.where(id: object.active_roles).pluck(:name).join(', ')
          end

          def order
            order = Order.find_by_id(options[:order_id]) if options[:order_id]
          end

        end
      end
    end
  end
end
