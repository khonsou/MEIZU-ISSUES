source 'http://ruby.taobao.org'
#source "http://rubygems.org"

gem 'rails', '3.2.8'
gem "mysql2", "~> 0.3.11"
gem "jquery-rails", "~> 2.0.2"
gem "i18n", "~> 0.6.0"
gem "coderay", "~> 1.0.6"
gem "fastercsv", "~> 1.5.0", :platforms => [:mri_18, :mingw_18, :jruby]
gem "builder", "3.0.0"
gem 'mini_magick', '~> 3.4'
gem "carrierwave", "~> 0.6.1"
gem "select2-rails", "~> 3.5.0"
gem 'delayed_job_active_record'
gem 'daemons'
gem "unicode-display_width"
#gem 'dropzonejs-rails'
gem "useragent"
gem "jquery-atwho-rails"
gem 'ruby-pinyin'
gem 'acts-as-taggable-on'
gem 'jbuilder'
gem 'ng-rails-csrf'
gem 'acts_as_list'
gem 'kaminari'
gem 'redis-rails'

group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'therubyracer', '~> 0.12.0'
  gem 'uglifier', '>= 1.2.3'
  gem 'bootstrap-sass', '~> 2.3.1.0'
  gem 'jquery-fileupload-rails', '~> 0.3.4'
end

group :development do
  gem "rdoc", ">= 2.4.2"
  gem "yard"
  gem 'awesome_print', '~> 1.0.2'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'quiet_assets'
end

group :test do
  gem "shoulda", "~> 2.11"
  # Shoulda does not work nice on Ruby 1.9.3 and seems to need test-unit explicitely.
  gem "test-unit", :platforms => [:mri_19]
  gem "mocha", "0.12.3"
end

# Optional gem for LDAP authentication
# group :ldap do
gem "net-ldap", "~> 0.3.1"
# end

# Optional gem for OpenID authentication
# group :openid do
gem "ruby-openid", "~> 2.1.4", :require => "openid"
gem "rack-openid"
# end

# Optional gem for exporting the gantt to a PNG file, not supported with jruby
# platforms :mri, :mingw do
#   group :rmagick do
#     # RMagick 2 supports ruby 1.9
#     # RMagick 1 would be fine for ruby 1.8 but Bundler does not support
#     # different requirements for the same gem on different platforms
gem "rmagick", ">= 2.0.0"
#   end
# end
