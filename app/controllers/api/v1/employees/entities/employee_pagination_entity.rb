module API
  module V1
    module Employees
      module Entities
        class EmployeePaginationEntity < API::BaseEntity
          expose :next, documentation: { type: 'Bool', desc: "Is something else in list of employees?" }, format_with: :bool
          expose :employees, using: API::V1::Employees::Entities::IndexEntity, documentation: {type: 'index_employee', is_array: true }
        end                
      end
    end
  end
end