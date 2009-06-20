
# Command:
#   $ rake app_config:generate_files

namespace :app_config do

  desc "Create a copy of all the app config files without the '.example' extension."
  task :generate_files do
    config_files = ['app_config.yml', 'bg_tasks.yml', 'database.yml', 'memcached.yml', 'environment.rb', 'schedule.rb']
    initializers = ['action_mailer.rb', 'session_store.rb', 'site_keys.rb']
    migrations   = ['099_create_app_data.rb']
    setup_files  = ['backup.rb', 'deploy.rb', 'passenger_stack.rb', 'server_setup.rb']

    root_path = File.expand_path(File.dirname(__FILE__) + '/../..')

    config_path = File.join(root_path, 'config')
    config_files.each do |f|
      file = File.join(config_path, f)
      FileUtils.copy_file("#{file}.example", file) unless File.exist?(file)
    end

    initializers_path = File.join(root_path, 'config/initializers')
    initializers.each do |i|
      file = File.join(initializers_path, i)
      FileUtils.copy_file("#{file}.example", file) unless File.exist?(file)
    end

    migrations_path = File.join(root_path, 'db/migrate')
    migrations.each do |m|
      file = File.join(migrations_path, m)
      FileUtils.copy_file("#{file}.example", file+'.xxx') unless File.exist?(file)
    end

    setup_path = File.join(root_path, 'setup')
    setup_files.each do |s|
      file = File.join(setup_path, s)
      FileUtils.copy_file("#{file}.example", file) unless File.exist?(file)
    end
  end
end