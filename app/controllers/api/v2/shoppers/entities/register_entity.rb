# frozen_string_literal: true

module API
  module V2
    module Shoppers
      module Entities
        class RegisterEntity < API::BaseEntity
          root 'shoppers', 'shopper'
        
          expose :id, documentation: { type: "Integer", desc: "Shopper's id" }, format_with: :integer
          expose :email, documentation: { type: "String", desc: "Shopper's email" }, format_with: :string
          expose :name, documentation: { type: "String", desc: "Shopper's name" }, format_with: :string
          expose :phone_number, documentation: { type: "String", desc: "Shopper's phone" }, format_with: :string
          expose :authentication_token, documentation: { type: "String", desc: "Shopper's authentication token needed for each request that needs authentication." }, format_with: :string
        end        
      end
    end
  end
end