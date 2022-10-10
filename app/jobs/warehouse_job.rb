# frozen_string_literal: true

class WarehouseJob
  @queue = :warehouse_jobs

  def self.perform(args = {})
    if args['inventory']
      partners = PartnerIntegration.where(integration_type: PartnerIntegration.integration_types[:cin7_inventory_update])
      PartnerIntegration::Cin7.new.get_data(partners) unless partners.blank?
    elsif args['modify_order']
      order = warehouse_order(args['order_id'])
      return unless order

      partner = warehouse_partner(PartnerIntegration.integration_types[:cin7_inventory_update])
      return unless partner

      PartnerIntegration::Cin7.new.modify_order(partner, order)
    elsif args['update_stage']
      order = warehouse_order(args['order_id'])
      return unless order

      partner = warehouse_partner(PartnerIntegration.integration_types[:cin7_inventory_update])
      return unless partner

      PartnerIntegration::Cin7.new.update_stage(partner, order)
    end
  end

  def self.warehouse_partner(type)
    @warehouse_partner ||= PartnerIntegration.find_by(retailer_id: warehouse_order.retailer_id, integration_type: type)
  end

  def self.warehouse_order(id = '')
    @warehouse_order ||= Order.find_by(id: id)
  end
end
