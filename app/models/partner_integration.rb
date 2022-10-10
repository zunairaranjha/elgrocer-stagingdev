class PartnerIntegration < ActiveRecord::Base
  belongs_to :retailer, optional: true

  before_save :trim_space
  after_save :create_locus_homebase

  def trim_space
    self.branch_code = self.branch_code.strip if self.branch_code.present?
  end

  # enum integration_type: {
  #   not_any: 0,
  #   fetch_price_stock: 1,
  #   post_order: 2,
  #   create_booking: 3
  # }

  enum integration_type: {
    not_any: 0, union_coop_fetch_stock_price: 1, union_coop_post_order: 2,
    getswift_post_order: 3, getswift_cancel_order: -3, one_click_post_order: 5,
    careem_post_order: 6, locus_post_order: 7, locus_cancel_order: -7,
    locus_assign_order: 8, locus_create_homebase: 9, locus_update_customfields: 10, locus_update_amount: 11,
    cin7_inventory_update: 12, locus_batch_post_order: 13, locus_batch_cancel_order: -13, locus_batch_reschedule_order: 14,
    locus_post_amount_update: 15, locus_batch_update_custom_fields: 20
  }

  # enum job_type: {job_type_none: 0, union_coop_post_order: 1, union_coop_fetch_stock_price: 2, one_click_post_order: 3, careem_post_order: 4, getswift_post_order: 5, getswift_cancel_order: 6, locus_post_order: 7, locus_cancel_oreder: 8}

  def create_locus_homebase
    if self.locus_post_order? || self.locus_batch_post_order?
      Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_create_homebase])
    end
  end

  # def is_locus_integration?
  #   PartnerIntegration.integration_types[self.integration_type] == PartnerIntegration.integration_types[:locus_post_order]
  # end

end
