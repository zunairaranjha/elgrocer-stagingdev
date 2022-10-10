module ProductIndexing
  extend ActiveSupport::Concern

  included do
    include Searchable

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 1,
      analysis: {
        analyzer: {
          stem: {
            tokenizer: "standard",
            filter: ["standard", "lowercase", "stop", "synonym", "porter_stem"]
          }
        },
        filter: {
          synonym: {
            type: "synonym",
            synonyms: File.readlines(Rails.root.join("config", "analysis", (Rails.env == "test" ? "test" : "data"), "product_synonym.txt")).map(&:chomp)
          },
          edgeNGram_filter: {
            type: 'edgeNGram',
            min_gram: 2,
            max_gram: 10,
            side: 'front'
          }
        }
      }
    } do
      mapping dynamic: 'true' do
        indexes :id, type: :integer
        indexes :name, analyzer: 'stem'
        indexes :name_ar, analyzer: 'stem'
        indexes :category_name, analyzer: 'stem'
        indexes :category_name_ar, analyzer: 'stem'
        indexes :subcategory_name, analyzer: 'stem'
        indexes :subcategory_name_ar, analyzer: 'stem'
        indexes :brand_name, analyzer: 'stem'
        indexes :brand_name_ar, analyzer: 'stem'
        indexes :description, analyzer: 'stem'
        indexes :description_ar, analyzer: 'stem'
        indexes :brand do
          indexes :id, type: :integer
          indexes :name
          indexes :name_ar
        end
      end
    end

    #
    # mapping do
    #   indexes :id, type: :integer
    #   indexes :name, type: :string
    #   indexes :description, type: :string
    #   indexes :created_at, type: :date

    #   indexes :categories, :type => "nested" do
    #     indexes :id, type: :integer
    #     indexes :name, type: :string
    #   end
    # end

  end
end
