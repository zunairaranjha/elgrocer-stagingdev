module CategoryIndexing
  extend ActiveSupport::Concern

  included do
    include Searchable

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0
    } do
      mapping do
        indexes :id, type: :integer
        indexes :name, type: :string
        indexes :subcategories, :type => "nested" do
          indexes :id, type: :string
          indexes :name, type: :string
          indexes :brands, :type => "nested" do
            indexes :id, type: :string
            indexes :name, type: :string
          end
        end
      end
    end
  end
end
