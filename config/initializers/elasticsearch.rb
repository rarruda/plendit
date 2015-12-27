
# Elasticsearch
Elasticsearch::Model.client = Elasticsearch::Client.new host: ( ENV['PCONF_ES_URL'] || ENV['SEARCHBOX_URL'] || 'localhost' ), log: ( Rails.env.development? ? true : false )
