module NameIndexing
  extend ActiveSupport::Concern

  included do
    include Searchable

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0
    } do
      mapping do
        indexes :id, type: :integer
        indexes :name, type: :text
      end
    end
  end
end
