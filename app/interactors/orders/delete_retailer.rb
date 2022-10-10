class Orders::DeleteRetailer < Orders::Base

    integer :order_id
    integer :retailer_id

    validate :order_exists
    validate :retailer_has_order
    validate :order_is_completed

    def execute
        mark_as_deleted!
        nil
    end

    private

    def order
        @order ||= Order.find(order_id)
    end

    def mark_as_deleted!
        Order.find(order_id).update(retailer_deleted: true)
    end

    def order_is_completed
        errors.add(:order_id, "The order is not completed!") unless order.status_id == 3
    end

end
