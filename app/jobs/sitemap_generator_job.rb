class SitemapGeneratorJob < ActiveJob::Base
  queue_as :low


  def perform
    puts "#{DateTime.now.iso8601} Starting SitemapGeneratorJob"

    #require 'rake'
    Plendit::Application.load_tasks

    if Rails.env.production?
      Rake::Task['sitemap:refresh'].invoke
    else
      Rake::Task['sitemap:create'].invoke
    end

    puts "#{DateTime.now.iso8601} Ending SitemapGeneratorJob"
  end

end
