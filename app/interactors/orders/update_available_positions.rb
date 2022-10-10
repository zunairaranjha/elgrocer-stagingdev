class Orders::UpdateAvailablePositions < Orders::Base

    integer :order_id
    integer :retailer_id
    array :positions

    validate :order_exists
    validate :retailer_has_order
    validate :positions_are_not_empty
    # validate :current_status_is_accepted

    def execute
        update_order_positions!
        order
    end

    private

    def order
        @order ||= Order.includes({order_positions: [:product, :shop]}, {promotion_code_realization: [:promotion_code]}, :delivery_slot).find(order_id)
    end

    def update_order_position!(position_data)
        # order_position = OrderPosition.find_by(id: position_data.position_id, order_id: order.id)
        (order.order_positions.detect {|s| s.id == position_data["position_id"] }).update!(was_in_shop: position_data["was_in_shop"])
    end

    def update_order_positions!
        positions.each do |position_data|
            update_order_position!(position_data)
        end
    end

    def current_status_is_accepted
       errors.add(:status_id, "Current status was not 'accepted'!") unless order.status_id == 1
    end

end
