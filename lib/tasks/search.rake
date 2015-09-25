namespace :search do
  desc 'Reindex'
  task :reindex => :environment do
    Ad.__elasticsearch__.delete_index!
    create_response = Ad.__elasticsearch__.create_index!

    ok = create_response && (create_response['acknowledged'] || create_response['ok'])
    ok or raise "unable to create #{elasticsearch.index_name}: #{create_response.inspect}"

    indexed_count = 0
    total = Ad.published.count

    Ad.published.import { |response|
        count     = response['items'].size
        took      = response['took']
        timed_out = response['timed_out']
        error     = response['items'].find { |e| e['index'] && e['index']['error'] }

        if error
          raise "reindex failed: #{error.inspect}"
        end

        if timed_out
          raise "reindex timed out: #{response.inspect}"
        end

        indexed_count += count
        puts "\t#{count.to_s.ljust(4)} (#{indexed_count}/#{total} in #{took}ms)"
      }
  end

end
