
# Elasticsearch
Elasticsearch::Model.client = Elasticsearch::Client.new host: ( ENV['SEARCHBOX_URL'] || 'localhost' ), log:  ( Rails.env == 'development' ? true : false )
