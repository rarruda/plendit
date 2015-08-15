namespace :export do
  desc "Prints Users.all in a seeds.rb way."
  task :seeds_format => :environment do
    puts "# ruby encoding: utf-8"
    puts
    [User, Location, Identity, Role, Ad, AdItem, AdImage, Booking, Message, Feedback, Notification, FavoriteList, FavoriteAd ].each do |c|
      puts "### #{c.to_s}"
      c.order(:id).all.each do |e|
        # also exclude 'id' if you are going to restore the database from scratch:
        # do a map.{}.to_h instead of just to_s, to fix issue with exporting values
        #   that are BigDecimal. In theory there could be values exported wrong from that.
        #puts "#{c.to_s}.create(#{e.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"

        puts "#{c.to_s}.create(#{e.serializable_hash.delete_if {|key, value| ['created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"
      end
      puts
      puts
    end
    puts "# EOF"
  end

  # This can fail if the original database has referential integrity issues.
  task :seeds_plendit => :environment do
    puts "# ruby encoding: utf-8"
    puts
    User.order(:id).where('id < 5').each do |u|
      puts
      puts "###"
      puts "###   User: #{u.id} - #{u.name}"
      puts "###"
      puts "u=User.create(#{u.serializable_hash.delete_if {|key, value| ['id','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"

      puts "#     locations"
      u.locations.order(:id).all.each do |l|
        puts "u.locations.create!(#{l.serializable_hash.delete_if {|key, value| ['id','user_id','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"
      end

      u.ads.order(:id).all.each do |a|
      puts "#     ads"
        puts "a=u.ads.create!(#{a.serializable_hash.delete_if {|key, value| ['id','location_id','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.push( ['location_id', u.locations.sample.id ] ).to_h})"

        puts "#       ad_images"
        a.ad_images.order(:id).all.each do |ai|
          puts "a.ad_images.create!(#{ai.serializable_hash.delete_if {|key, value| ['id','ad_id','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"
        end
      end

      puts "#     roles"
      u.roles.order(:id).all.each do |r|
        puts "u.roles.create!(#{r.serializable_hash.delete_if {|key, value| ['id','resource_id','resource_type','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"
      end

      puts "#     identities"
      u.identities.order(:id).all.each do |i|
        puts "u.identities.create!(#{i.serializable_hash.delete_if {|key, value| ['id','user_id','created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"
      end

      puts
      puts
      ### NOTE: [Message, Feedback, Booking, FavoriteList, FavoriteAd] are not exported.
    end
  end
end
