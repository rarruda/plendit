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
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :keep_releases, 10

set :passenger_restart_with_touch, true

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
  before :starting,     :loadbalancer_check_off
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
  after  :finished,     :loadbalancer_check_on
end


