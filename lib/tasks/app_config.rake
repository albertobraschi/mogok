
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
      FileUtils.copy_file(File.join(config_path, "#{f}.example"), File.join(config_path, f+'.xxx'))
    end

    initializers_path = File.join(root_path, 'config/initializers')
    initializers.each do |i|
      FileUtils.copy_file(File.join(initializers_path, "#{i}.example"), File.join(initializers_path, i+'.xxx'))
    end

    migrations_path = File.join(root_path, 'db/migrate')
    migrations.each do |m|
      FileUtils.copy_file(File.join(migrations_path, "#{m}.example"), File.join(migrations_path, m+'.xxx'))
    end

    setup_path = File.join(root_path, 'setup')
    setup_files.each do |s|
      FileUtils.copy_file(File.join(setup_path, "#{s}.example"), File.join(setup_path, s+'.xxx'))
    end
  end
end