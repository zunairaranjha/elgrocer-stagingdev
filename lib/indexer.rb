class Indexer
  @queue = :indexer_queue

  def self.perform(operation, klass_name, id)
    case operation.to_s
      when /create/
        Indexer.create(klass_name, id)
      when /update/
        Indexer.update(klass_name, id)
      when /delete/
        Indexer.delete(klass_name, id)
      when /update_rank/
        Indexer.update_rank(klass_name, id)
      when /bulk_index/
        Indexer.bulk_index(klass_name, id)
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end

  def self.create(klass_name, id)
    doc = klass_name.constantize.find(id)
    doc.__elasticsearch__.index_document
    # doc.try(:bulk_index) # seems good to call bulk_index
  end

  def self.update(klass_name, id)
    doc = klass_name.constantize.find(id)
    doc.__elasticsearch__.update_document
  end

  def self.delete(klass_name, id)
    # it's already deleted, so we have to delete it old school
    doc = klass_name.constantize.new
    doc.id = id
    doc.__elasticsearch__.delete_document
  end

  def self.update_rank(klass_name, id)
    doc = klass_name.constantize.find(id)
    doc.__elasticsearch__.update_document_attributes product_rank: doc.product_rank.to_f
  end

  def self.bulk_index(klass_name, id)
    doc = klass_name.constantize.find(id)
    doc.bulk_index
  end
end
