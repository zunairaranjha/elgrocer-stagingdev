module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name "elgrocer_#{Rails.env}_#{index_name}"
    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      store: { type: :memory },
      analysis: {
        analyzer: {
          default: { type: 'keyword' }
        }
      }
    } if Rails.env.test?

    def self.search(query, extra={})
      my_query = \
        {
          sort: [
            # {id: 'asc'},
            '_score'
          ]
        }
      my_query[:query] =  if query.blank?
                            {match_all: {}}
                          elsif query.is_a? String
                            query.downcase
                          else
                            query
                          end

      extra.each do |k,v|
        my_query[k] = v
      end
      
      my_query = query if query.is_a? String

      __elasticsearch__.search(my_query)
    end

    def self.string_search(query)
      __elasticsearch__.search(query)
    end

    def self.align_score(query)
      {
        "function_score": {
            "query": query,  "field_value_factor": {
                "field": "product_rank",
                "missing": 1
            }
        }
      }
    end
  end
end
