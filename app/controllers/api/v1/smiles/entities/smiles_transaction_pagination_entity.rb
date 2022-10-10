module API
  module V1
    module Smiles
      module Entities
        class SmilesTransactionPaginationEntity < API::BaseEntity
          expose :next, documentation: { type: 'Bool', desc: "Is something else in list of smiles transactions?" }, format_with: :bool
          expose :transactions, using: API::V1::Smiles::Entities::SmilesTransactionEntity, documentation: {type: 'SmilesTransactionEntity', is_array: true }
        end
      end
    end
  end
end