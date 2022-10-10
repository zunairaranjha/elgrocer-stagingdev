class UcStockUpdateJob
  @queue = :partner_integration_queue

  def self.perform
    partners = PartnerIntegration.where(integration_type: 1)
    PartnerIntegration::UnionCoopUpdateStock.new.get_data(partners)
  end
end
