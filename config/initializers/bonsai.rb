ENV['BONSAI_URL'] ||= 'http://127.0.0.1:9200'

#Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['BONSAI_URL']