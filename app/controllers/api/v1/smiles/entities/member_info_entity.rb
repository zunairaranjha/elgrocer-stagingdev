module API
  module V1
    module Smiles
      module Entities
        class MemberInfoEntity < API::BaseEntity

          expose :name, documentation: { type: 'String', desc: 'Name Of Member' }, format_with: :string
          expose :available_points, documentation: { type: 'Integer', desc: 'Smiles Points' }, format_with: :integer
          expose :is_blocked, documentation: { type: 'Bool', desc: 'Smiles Points' }, format_with: :bool
          expose :tier_level, documentation: { type: 'String', desc: 'Tier level Of Member' }, format_with: :string
          expose :food_subscription_status, documentation: { type: 'Bool', desc: 'food_subscription_status of Smiles' }, format_with: :bool

          def name
            "#{object['getMemberResponse']['accountsInfo'][0]['firstName']} #{object['getMemberResponse']['accountsInfo'][0]['lastName']}"
          end

          def available_points
            object['getMemberResponse']['accountsInfo'][0]['totalPoints'].to_i + options[:burn_points].to_i
          end

          def is_blocked
            object['getMemberResponse']['accountsInfo'][0]['accountStatus'] != 'Active'
          end

          def tier_level
            object['getMemberResponse']['accountsInfo'][0]['tierLevel']
          end

          def food_subscription_status
            # object['getMemberResponse']['accountsInfo'][0]['foodSubscriptionStatus']
            false
          end
        end
      end
    end
  end
end
