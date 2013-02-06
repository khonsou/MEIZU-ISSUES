desc 'Load Redmine default configuration data. Language is chosen interactively or by setting REDMINE_LANG environment variable.'

namespace :redmine do
  task :load_default_data => :environment do
    include Redmine::I18n
    set_language_if_valid('zh')

    begin
      Redmine::DefaultData::Loader.load(current_language)
      puts "Default configuration data loaded."
    rescue Redmine::DefaultData::DataAlreadyLoaded => error
      puts error.message
    rescue => error
      puts "Error: " + error.message
      puts "Default configuration data was not loaded."
    end
  end
end
