# frozen_string_literal: true

module API
  module V1
    module Employees
      module Entities
        class EmployeeInOrderEntity < API::BaseEntity

          expose :id, documentation: { type: 'Integer', desc: 'ID of the employee' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of employee' }, format_with: :string
          expose :registration_id, documentation: { type: 'String', desc: 'Push Token' }, format_with: :string
        end
      end
    end
  end
end
