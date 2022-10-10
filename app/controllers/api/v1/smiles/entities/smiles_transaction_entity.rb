module API
  module V1
    module Smiles
      module Entities
        class SmilesTransactionEntity < API::BaseEntity
          expose :event, documentation: { type: 'String', desc: 'event of transactions' }, format_with: :string
          expose :transaction_ref_id, documentation: { type: 'String', desc: 'transaction ref id' }, format_with: :string
          expose :transaction_id, documentation: { type: 'String', desc: 'transaction ref id' }, format_with: :string
          expose :order_id, documentation: { type: 'Integer', desc: 'Id of order' }, format_with: :integer
          expose :conversion_rule, documentation: { type: 'String', desc: 'Id of order' }, format_with: :integer
          expose :total_smiles_points, documentation: { type: 'Integer', desc: 'Id of order' }, format_with: :integer

          def total_smiles_points
            object.details['request']['spend_value'] || object.details['request']['points_value']
          end
        end
      end
    end
  end
end