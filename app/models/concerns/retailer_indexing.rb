module RetailerIndexing
  extend ActiveSupport::Concern

  included do
    include Searchable


    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0
    } do
      mapping do
        indexes :id, type: :integer
        indexes :company_name, type: :text
        indexes :opening_time, type: :text
        indexes :company_address, type: :text

        indexes :created_at, type: :date
        # indexes :brands, :type => "nested" do
        #   indexes :id, type: :string
        #   indexes :name, type: :string
        # end
        # indexes :categories, :type => "nested" do
        #   indexes :id, type: :string
        #   indexes :name, type: :string
        # end
      end
    end
  end
end
