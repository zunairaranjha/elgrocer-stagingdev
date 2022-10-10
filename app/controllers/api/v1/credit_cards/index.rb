# frozen_string_literal: true

module API
  module V1
    module CreditCards
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :credit_cards do
          desc 'List of all credit cards of current shopper. Requires authentication', entity: API::V1::CreditCards::Entities::ShowEntity

          get do
            if current_shopper.blank?
              error!({ error_code: 401, error_message: 'You are not logged in!' }, 401)
            else
              cards = current_shopper.credit_cards.where('is_deleted = ? AND expiry_year < ?', false, 100).order(:id)
              present cards, with: API::V1::CreditCards::Entities::ShowEntity
            end
          end
        end
      end
    end
  end
end
