# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'plendit'
set :repo_url, 'git@gitlab.com:plendit/plendit.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, '/var/www/plendit'

# Default value for :scm is :git
# set :scm, :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, fetch(:linked_files, []).push('config/env.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/sitemaps')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :keep_releases, 10

set :passenger_restart_with_touch, true


# capistrano-resque
# https://github.com/sshingler/capistrano-resque
set :resque_environment_task, true
#If you need to pass arbitrary data (like other non-standard environment variables) to the "start" command:
#set :resque_extra_env, "SEARCH_SERVER=172.18.0.52"
set :interval, "10"
set :resque_log_file, 'log/resque.log'

set :workers, {
  "high" => 1,
  #"mailers" => 1,
  "*" => 1,
}


# slackistrano
set :slack_webhook, ENV['PCONF_SLACK_WEBHOOK_CAPISTRANO']

#set :slack_via_slackbot, true
#set :slack_team, "plendit"
#set :slack_token, "xxxxxxxxxxxxxxxxxxxxxxxx"
#set :slack_channel, '#notifications-events'
set :slack_username, -> { 'Capistrano' }
set :slack_revision, `git rev-parse origin/master`.strip!
set :slack_title_finished,    -> { nil }
set :slack_msg_finished,      -> { nil }
set :slack_fallback_finished, -> { "#{fetch(:slack_deploy_user)} deployed #{fetch(:application)} on #{fetch(:stage)}" }
set :slack_commit_history,    -> { %x(git log --format='%h %an: %s' #{fetch(:previous_revision)}^..HEAD) }
set :slack_fields_finished, [
  {
    title: "Project",
    value: "<https://gitlab.com/plendit/#{fetch(:application)}|#{fetch(:application)}>",
    short: true
  },
  {
    title: "Environment",
    value: fetch(:stage),
    short: true
  },
  {
    title: "Deployer",
    value: fetch(:slack_deploy_user),
    short: true
  },
  {
    title: "Revision",
    value: "<https://gitlab.com/plendit/#{fetch(:application)}/commit/#{fetch(:slack_revision)}|#{fetch(:slack_revision)[0..6]}>",
    short: true
  } #,
  # {
  #   title: "Commits",
  #   value: "h: #{fetch(:slack_commit_history)}",
  #   short: false
  # }
]

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'passenger:restart'
    end
  end

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'passenger:start'
      invoke 'deploy'
    end
  end

  desc 'Remove loadbalancer check file'
  task :loadbalancer_check_off do
    on roles(:app) do
      execute :rm, "-f", "#{shared_path}/public/lb.html"
      puts "Removed app from loadbalancer"
      sleep 5
    end
  end

  desc 'Add loadbalancer check file'
  task :loadbalancer_check_on do
    on roles(:app) do
      execute :touch,  "#{shared_path}/public/lb.html"
      puts "Added app to loadbalancer"
      sleep 5
    end
  end

  before :starting,     :check_revision
  #before :starting,     :loadbalancer_check_off
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
  after :finished,      'airbrake:deploy'
  #after  :finished,     :loadbalancer_check_on

  after 'deploy:restart', 'resque:restart'
  after 'deploy:restart', 'resque:scheduler:restart'
end

namespace :search do
  desc 'Reindex'
  task :reindex do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "search:reindex"
        end
      end
    end
  end
end

