module API
  module V1
    module CollectorDetails
      module Entities
        class IndexEntity < API::BaseEntity

          expose :id, documentation: { type: 'Integer', desc: 'id of Collector' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of Collector' }, format_with: :string
          expose :collector_phone, as: :phone_number, documentation: { type: 'String', desc: 'Phone no of collector' }, format_with: :string

          private

          def collector_phone
            if object.phone_number
              object.phone_number.length > 10 ? object.phone_number.phony_formatted(format: :+, spaces: '') : object.phone_number.phony_normalized
            else
              nil
            end
          end
        end
      end
    end
  end
end
