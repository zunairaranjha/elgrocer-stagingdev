ActiveAdmin.register Order, as: 'Reschedule Order' do
  menu false
  actions :all, except: %i[new destroy show]
  permit_params :estimated_delivery_at, :delivery_slot_id, :updated_at

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Status' do
      f.input :delivery_slot_id, as: :select, collection: controller.next_slots.map { |n| ["#{n.slot_start.to_date} #{n.name}", n.id] }
    end
    f.actions
  end

  controller do
    def update
      order = Order.find_by(id: resource.id)

      order.estimated_delivery_at = RetailerAvailableSlot.find(params[:order][:delivery_slot_id]).slot_start
      order.updated_at = Time.now
      order.delivery_slot_id = params[:order][:delivery_slot_id]
      order.save!

      OrderDataStreamingJob.perform_later(order, 8)
      Analytic.add_activity('Order Rescheduled', order)
      order.shopper.update_order_notify(order, I18n.t('message.reschedule_order', date_time: order.estimated_delivery_at.try(:strftime, '%y-%m-%d %H:%M')))

      if Analytic.joins(:event).where(owner: order, "events.name": 'Locus Task Created').exists?
        order.cancel_locus_task if JSON(Analytic.joins(:event).where(owner: order, "events.name": 'Locus Task Assigned').last&.detail)['assignedUser'].present?
        order.create_locus_task
        # order.assign_locus_task if assigned > 0
      elsif Analytic.joins(:event).where(owner: order, "events.name": 'Locus Batch Task Created').exists?
        order.reschedule_locus_batch_task
        # Resque.enqueue(PartnerIntegrationJob, order.id, PartnerIntegration.integration_types[:locus_batch_reschedule_order])
      end
      redirect_to admin_order_path(order.id)
    end

    def next_slots
      available_slots =
        if resource.retailer_service_id == 1
          RetailerAvailableSlot.where("retailer_delivery_zone_id = #{resource.retailer_delivery_zone_id} and retailer_service_id = 1 and retailer_id = #{resource.retailer_id} ")
        else
          RetailerAvailableSlot.where("retailer_service_id = 2 and retailer_id = #{resource.retailer_id} ")
        end
      available_slots.where("total_limit = 0 OR (total_limit + total_margin) >= (total_products + #{resource.order_positions.where(was_in_shop: true).sum('amount')})")
                     .order(:slot_rank).first(36)
    end

  end
end