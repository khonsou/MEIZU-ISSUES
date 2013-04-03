set :stages, %w(demo production)
set :default_stage, "production"
require 'capistrano/ext/multistage'
