# frozen_string_literal: true

class PartnerIntegrationJob
  @queue = :partner_integration_queue

  def self.perform(*args)
    case args.length
    when 1
      # ActiveRecord::Base.connection.execute("delete from orders where id in (SELECT id FROM  (SELECT id, ROW_NUMBER() OVER( PARTITION BY shopper_id, retailer_id, date(created_at), total_value, shopper_address_id, delivery_slot_id  ORDER BY estimated_delivery_at ) AS row_num FROM orders where created_at >= '#{(Time.now - 4.minute).utc}' and created_at <= '#{Time.now.utc}' and estimated_delivery_at >= '#{Time.now.utc}' and status_id not in (-1,4) and retailer_id <> 16) t WHERE t.row_num > 1)") rescue ''
      return unless order(args)

      partners = get_partners([PartnerIntegration.integration_types[:cin7_inventory_update], PartnerIntegration.integration_types[:union_coop_post_order]])
      return if partners.blank?

      partners.each do |p|
        if p.union_coop_post_order?
          PartnerIntegration::UnionCoop.new(order, p).create_new_order
        elsif p.cin7_inventory_update?
          PartnerIntegration::Cin7.new.post_order(p, order)
        end
      end
    when 2
      case args[1]
      when 0
        PartnerIntegration::OneClick.new(args[0]).create_booking
      when 1
        PartnerIntegration::Careem.new(args[0]).create_booking
      when 2
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Booking Created') && partner(PartnerIntegration.integration_types[:getswift_post_order], '')
          # partner =  PartnerIntegration.find_by(retailer_id: order.retailer_id, integration_type: 3)
          PartnerIntegration::GetSwift.new(order).create_booking(@partner)
        end
      when 3
        if order(args[0]) && analytic('Booking Created')
          PartnerIntegration::GetSwift.new(order).cancel_booking(JSON(analytic.detail)['delivery']['id'], order.message.to_s)
        end
      when PartnerIntegration.integration_types[:locus_post_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && (!analytic_exists?('Locus Task Created') || analytic_exists?('Order Rescheduled')) && partner(PartnerIntegration.integration_types[:locus_post_order], '')
          PartnerIntegration::LocusSh.new(order).create_booking(@partner)
        end
        #     ****Process orders in Batches using Locus OrderIQ****
      when PartnerIntegration.integration_types[:locus_batch_post_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && (!analytic_exists?('Locus Batch Task Created') || analytic_exists?('Order Rescheduled')) && partner(PartnerIntegration.integration_types[:locus_batch_post_order], '')
          PartnerIntegration::LocusSh.new(order).batch_create_booking(@partner)
        end
      when PartnerIntegration.integration_types[:locus_assign_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Task Created') && partner(PartnerIntegration.integration_types[:locus_post_order], '')
          PartnerIntegration::LocusSh.new(order).assign_booking(@partner)
        end
      when PartnerIntegration.integration_types[:locus_cancel_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Task Created') && partner(PartnerIntegration.integration_types[:locus_post_order], '')
          PartnerIntegration::LocusSh.new(order).cancel_booking(@partner, order.message.to_s)
        end
        #     ****Process orders in Batches using Locus OrderIQ****
      when PartnerIntegration.integration_types[:locus_batch_cancel_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Batch Task Created') && partner(PartnerIntegration.integration_types[:locus_batch_post_order], '')
          PartnerIntegration::LocusSh.new(order).batch_cancel_booking(@partner, order.message.to_s)
        end
        #     ****Process orders in Batches using Locus OrderIQ****
      when PartnerIntegration.integration_types[:locus_batch_reschedule_order]
        if order(args[0])&.retailer_service_id.to_i == 1 && (!analytic_exists?('Locus Batch Task Created') || analytic_exists?('Order Rescheduled')) && partner(PartnerIntegration.integration_types[:locus_batch_post_order], '')
          PartnerIntegration::LocusSh.new(order).reschedule_order(@partner)
        end
      when PartnerIntegration.integration_types[:locus_create_homebase]
        if (partner = PartnerIntegration.find_by(id: args[0], integration_type: [PartnerIntegration.integration_types[:locus_post_order], PartnerIntegration.integration_types[:locus_batch_post_order]]))
          PartnerIntegration::LocusSh.new(nil).create_homebase(partner)
        end
      when PartnerIntegration.integration_types[:locus_update_customfields]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Task Created') && partner(PartnerIntegration.integration_types[:locus_post_order], '')
          PartnerIntegration::LocusSh.new(order).update_customfields(@partner)
        end
        #*** Batch OrderIQ ***
      when PartnerIntegration.integration_types[:locus_batch_update_custom_fields]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Batch Task Created') && partner(PartnerIntegration.integration_types[:locus_batch_post_order], '')
          PartnerIntegration::LocusSh.new(order).update_egorder_status(@partner)
        end
      when PartnerIntegration.integration_types[:locus_update_amount]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Task Created') && partner(PartnerIntegration.integration_types[:locus_post_order],'')
          PartnerIntegration::LocusSh.new(order).update_amount(@partner)
        end
      when PartnerIntegration.integration_types[:locus_post_amount_update]
        if order(args[0])&.retailer_service_id.to_i == 1 && analytic_exists?('Locus Batch Task Created') && partner(PartnerIntegration.integration_types[:locus_batch_post_order],'')
          PartnerIntegration::LocusSh.new(order).locus_post_update_amount(@partner)
        end
      end
    # else
    #   partners = PartnerIntegration.where(integration_type: 1)
    #   PartnerIntegration::UnionCoopFetchPriceStock.new.get_data(partners)
    end
  end

  def self.analytic_exists?(event)
    Analytic.joins(:event).where(owner: order, "events.name": event).exists?
  end

  def self.order(id = '')
    @order ||= Order.find_by(id: id)
  end

  def self.partner(type, branch = nil)
    @partner ||=
      branch.nil? ? PartnerIntegration.find_by(retailer_id: order.retailer_id, integration_type: type) : PartnerIntegration.find_by(retailer_id: order.retailer_id, integration_type: type, branch_code: ['', order.retailer_delivery_zone_id])
  end

  def self.get_partners(type)
    PartnerIntegration.where(retailer_id: order.retailer_id, integration_type: type)
  end

  def self.analytic(event = '')
    @analytic ||= Analytic.joins(:event).find_by(owner: order, "events.name": event)
  end

end
