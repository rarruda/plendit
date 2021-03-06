#require 'elasticsearch/model'
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    #include Elasticsearch::Model::Callbacks
    #mapping do
    #  # ...
    #end

    def self.h_to_number num
      num.to_i * 100 unless num.nil?
    end

    # for now tuned to act as Ad.search
    def self.search(query, filter = nil, options = {})

      # SEE: https://github.com/elastic/elasticsearch-rails/blob/templates/elasticsearch-rails/lib/rails/templates/searchable.rb#L76-L222
      # for an example of query builder.
      __set_filters = lambda do |filter|
        @search_definition[:filter][:and] ||= []
        @search_definition[:filter][:and]  |= [filter]
      end

      @search_definition = {
        query: {},
        filter: {}
      }

      # no query sent, so search for everything:
      if query.blank?
        @search_definition[:query] = {
          match_all: { }
        }
      else
        @search_definition[:query] = {
          multi_match: {
            query: query,
            fields: ['title^4','body^2','images.description','tags']
            # using _all field in ES2.1.1 creates null_pointer_exception on
            #  zero hits, for nested documents.
          }
        }
      end

      if options.has_key? 'tag'
        __set_filters.({
            match: {
              tags: options[:tag]
            }
        })
      end

      if options.has_key? 'price_min'
        __set_filters.({
          range: {
            price: {
              gte: self.h_to_number( options[:price_min] )
            }
          }
        })
      end
      if options.has_key? 'price_max'
        __set_filters.({
          range: {
            price: {
              lte: self.h_to_number( options[:price_max] )
            }
          }
        })
      end

      if options.has_key? 'category'
        __set_filters.({
          terms: {
            category: options[:category]
          }
        })
      end

      if options.has_key?('ne_lat') && options.has_key?('ne_lon') &&
        options.has_key?('sw_lat') && options.has_key?('sw_lon')
        __set_filters.({
          geo_bounding_box: {
            geo_location: {
              top_right: {
                lat: options[:ne_lat],
                lon: options[:ne_lon]
              },
              bottom_left: {
                lat: options[:sw_lat],
                lon: options[:sw_lon]
              }
            }
          }
        })
      end


      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-sort.html
      # if options.has_key? 'sort'
      #   @search_definition[:sort]  = { options['sort'] => 'desc' }
      #   @search_definition[:track_scores] = true
      # else
        @search_definition[:track_scores] = true
        @search_definition[:sort]  = { _score: 'desc', created_at: 'desc' }
      # end

      # If a filter is sent, the attach it to the search_definition:
      if not filter.blank?
        __set_filters.(filter)
      end

      # Always include geo_location in result set:
      @search_definition[:fielddata_fields] = ['geo_location','geo_location.geohash']


      #LOG.debug message: JSON.pretty_generate @search_definition
      __elasticsearch__.search( @search_definition )
    end
  end
end
