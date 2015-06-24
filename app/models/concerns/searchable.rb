#require 'elasticsearch/model'
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    #include Elasticsearch::Model::Callbacks
    #mapping do
    #  # ...
    #end

    # for now tuned to act as Ad.search
    def self.search(query, filter, options = nil)
      # no query sent, so search for everything:
      if query.nil?
        _q = {
          match_all: { }
        }
      else
#        _q = {
#          match: {
#            _all: query
#          }
#        }
        # query with boosting:
        _q = {
          multi_match: {
            query: query,
            fields: ['title^3','body^2','_all']
          }
        }
      end

      # If a filter is sent, the attach it to the query:
      if filter.nil?
        q = {
          query: _q
        }
      else
        q = {
          query: {
            filtered: {
              query: _q,
              filter: filter
            }
          }
        }
      end

      __elasticsearch__.search(q)
    end
  end
end
