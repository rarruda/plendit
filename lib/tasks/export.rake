namespace :export do
  desc "Prints Profiles.all in a seeds.rb way."
  task :seeds_format => :environment do
    [Profile, ProfileStatus, Ad, Feedback, AdItem, Booking, Message].each do |c|
    #[Ad ].each do |c|
      puts "### #{c.to_s}"
      c.order(:id).all.each do |e|
        # also exclude 'id' if you are going to restore the database from scratch:
        # do a map.{}.to_h instead of just to_s, to fix issue with exporting values
        #   that are BigDecimal. In theory there could be values exported wrong from that.
        #puts "#{c.to_s}.create(#{e.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"

        puts "#{c.to_s}.create(#{e.serializable_hash.delete_if {|key, value| ['created_at','updated_at'].include?(key)}.map{ |k,v| [k, v.to_s] }.to_h})"

      end
      puts "\n\n"
    end
  end
end
