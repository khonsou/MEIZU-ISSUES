set :application, "plano"
set :user, "ubuntu"
set :application_root, "/rails_apps/#{application}"

ssh_options[:port] = 16120
set :deploy_to, application_root
set :use_sudo, false

set :scm, :git
set :git_shallow_clone, 1
set :copy_exclude, [".git/*", ".gitignore"]

# to avoid "find .../public/images" error
set :normalize_asset_timestamps, false

role :app, *application_servers
role :web, *application_servers
role :db, migration_server, :primary => true

deploy.task :start, :roles => [:app] do
  run "touch #{current_release}/tmp/restart.txt"
end

deploy.task :stop, :roles => [:app] do
  # Do nothing.
end

deploy.task :restart, :roles => [:app] do
  run "touch #{current_release}/tmp/restart.txt"
end

task :create_bundler_config_file, :roles => [:app] do
  run "mkdir #{release_path}/.bundle"
  run "echo \"---\" > #{release_path}/.bundle/config"
  run "echo \"BUNDLE_WITHOUT: development:test\" >> #{release_path}/.bundle/config"
end

task :copy_database_yml_file, :roles => [:app] do
  run "cp #{application_root}/shared/data/database.yml #{release_path}/config/database.yml"
end

after "deploy:update_code", :copy_database_yml_file, :create_bundler_config_file

