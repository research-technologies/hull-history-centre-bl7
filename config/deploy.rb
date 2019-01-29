# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'hull-history-centre'
set :repo_url, 'git@github.com:uohull/hull-history-centre.git'
set :branch, 'master'
set :deploy_to, '/opt/hull-history-centre'
set :scm, :git
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :assets_prefix, "#{shared_path}/public/assets"
# to deploy with a separate assets folder, use release_path:
# set :assets_prefix, "#{release_path}/public/assets"

set :linked_files, %w{config/database.yml config/solr.yml config/secrets.yml config/initializers/blacklight_google_analytics.rb}

set :linked_dirs, %w{tmp/pids tmp/cache tmp/sockets public/assets}
# to deploy with a separate assets folder, remove public/assets from linked dirs:
# set :linked_dirs, %w{tmp/pids tmp/cache tmp/sockets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "touch #{release_path}/tmp/restart.txt"
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
      execute :rake, 'tmp:clear'
      end
    end
  end

end
