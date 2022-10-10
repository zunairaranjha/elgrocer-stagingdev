# frozen_string_literal: true

module API
  module V1
    module Versions
      module Entities
        class CheckVersionEntity < API::BaseEntity
          expose :action, documentation: { type: 'Integer', desc: 'Action: [0,1,2]' }, format_with: :integer
          expose :message, if: :type, documentation: { type: 'String', desc: 'Message' }, format_with: :string
        end                
      end
    end
  end
end