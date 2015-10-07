# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'plendit'
set :repo_url, 'git@gitlab.com:plendit/plendit.git'
set :rbenv_ruby, '2.1.6'

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

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :keep_releases, 10

set :puma_threads,    [4, 16]
set :puma_workers,    2
#####set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
#####set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
#####set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
#####set :puma_access_log, "#{release_path}/log/puma.error.log"
#####set :puma_error_log,  "#{release_path}/log/puma.access.log"
#####set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
#####set :puma_preload_app, true
#####set :puma_worker_timeout, nil
#####set :puma_init_active_record, true  # Change to false when not using ActiveRecord


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
      invoke 'puma:restart'
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
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end


