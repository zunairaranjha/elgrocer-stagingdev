module API
  module V1
    module Employees
      module Entities
        class ActivityEntity < API::BaseEntity
          root 'activities', 'activity'
        
          def self.entity_name
            'show_employee_activities'
          end
        
          expose :event_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :order_id, documentation: { type: 'Integer', desc: 'Order ID' }, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Activity Created Time' }, format_with: :string
        
        
          private
          def event_name
            object.event.try(:name)
          end
        end
                
      end
    end
  end
end