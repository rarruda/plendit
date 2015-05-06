namespace :export do
  desc "Prints Users.all in a seeds.rb way."
  task :seeds_format => :environment do
    puts "# ruby encoding: utf-8"
    puts
    [User, UserStatus, Ad, AdItem, AdImage, Feedback, Booking, BookingStatus, Message, Location].each do |c|
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
end
