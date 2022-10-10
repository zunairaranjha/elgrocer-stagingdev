module API
  module V1
    module Employees
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        mount API::V1::Employees::Index
        mount API::V1::Employees::EmployeeDetail
        mount API::V1::Employees::GetRoles
        mount API::V1::Employees::AssignRole
        mount API::V1::Employees::AddActivity
        mount API::V1::Employees::AllocateOrder
        mount API::V1::Employees::ShopperDetailReason
      end
      
    end
  end
end