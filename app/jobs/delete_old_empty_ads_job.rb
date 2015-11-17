class DeleteOldEmptyAdsJob
  def self.queue
    :ads
  end

  def self.perform( age = 30.days ) #( age = 6.hours )
    puts "#{DateTime.now.iso8601} Starting DeleteOldAdsJob"

    deleted_ads = Ad.all.unscoped.never_edited.where("created_at < ?", ( DateTime.now - age ) ).destroy_all
    if deleted_ads.length > 0
      puts "Deleted #{deleted_ads.length} ads."
      puts "List of ids deleted: #{deleted_ads.map{|a| a.id}}"
    end

    puts "#{DateTime.now.iso8601} Ending DeleteOldAdsJob"
  end
end