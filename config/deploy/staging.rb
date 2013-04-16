set :repository, "git://github.com/khonsou/MEIZU-ISSUES.git"
set :application_servers, %w(ubuntu)
set :migration_server, "ubuntu"
set :user, "ubuntu"
set :rails_env, "staging"
set :branch, "master"
set :deploy_via, :remote_cache

load File.dirname(__FILE__) + "/shared_code"

task :assets_precompile, :roles => [:app] do
  run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile 2>/dev/null"
end

after "deploy:update_code", :assets_precompile
