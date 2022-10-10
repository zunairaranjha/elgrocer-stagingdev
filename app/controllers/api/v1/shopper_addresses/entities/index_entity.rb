module API
    module V1
        module ShopperAddresses
            module Entities
                class IndexEntity < API::BaseEntity
                    expose :addresses, using: API::V1::ShopperAddresses::Entities::ShowEntity, documentation: {type: 'show_address', is_array: true }
                end          
            end
        end
    end
end