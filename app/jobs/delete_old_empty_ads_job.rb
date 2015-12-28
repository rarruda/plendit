class DeleteOldEmptyAdsJob
  def self.queue
    :low
  end

  def self.perform( age = 15.days )
    puts "#{DateTime.now.iso8601} Starting #{self.class.name}"
    puts "#{DateTime.now.iso8601} Starting DeleteOldEmptyAdsJob"

    deleted_ads = Ad.all.unscoped.never_edited.where("created_at < ?", ( DateTime.now - age ) ).destroy_all
    if deleted_ads.length > 0
      puts "Deleted #{deleted_ads.length} ads."
      puts "List of ids deleted: #{deleted_ads.map(&:id).join(',')}"
    end

    puts "#{DateTime.now.iso8601} Ending DeleteOldEmptyAdsJob"
    puts "#{DateTime.now.iso8601} Ending #{self.class.name}"
  end
end