
set :application, 'mogok'

# server
  set :domain, 'localhost'
  set :port, 2222

# user
  Capistrano::CLI.ui.say('SETUP - Please provide the user credentials (must have sudo privileges):')
  set :user, 'user'#    Capistrano::CLI.ui.ask(' > username: ')
  set :password, 'rewfva'#Capistrano::CLI.password_prompt(' > password: ')
  set :use_sudo, false

# database root
  Capistrano::CLI.ui.say('Please provide the database root user password:')
  set :db_root_password, 'root'#Capistrano::CLI.password_prompt(' > password: ')

# roles
  role :app, domain
  role :db,  domain, :primary => true

# paths
  set :apps_path, '/var/vhosts'
  set :app_root_path, "#{apps_path}/#{application}"

# app user
  Capistrano::CLI.ui.say('Please provide the information for the app user that will be created in the server:')
  set :app_user, 'mogok'#                      Capistrano::CLI.ui.ask(' > username: ')
  set :app_user_password, 'rrrrrr'#             Capistrano::CLI.password_prompt(' > password: ')
  set :app_user_password_confirmation, 'rrrrrr'#Capistrano::CLI.password_prompt(' > confirm.: ')
  raise 'password must match password confimation' if app_user_password != app_user_password_confirmation

  Capistrano::CLI.ui.say('Please provide the app user group (www-data on Ubuntu, for others is the group in which Apache runs):')
  set :app_user_group, 'www-data'#                Capistrano::CLI.ui.ask(' > group: ')

# database user
  Capistrano::CLI.ui.say('Please provide the information for the user that will be created in the database:')
  set :db_user, 'mogok'#                      Capistrano::CLI.ui.ask(' > username: ')
  set :db_user_password, 'rrrrr'#             Capistrano::CLI.password_prompt(' > password: ')
  set :db_user_password_confirmation, 'rrrrr'#Capistrano::CLI.password_prompt(' > confirm.: ')
  raise 'password must match password confimation' if db_user_password != db_user_password_confirmation

# passenger
  Capistrano::CLI.ui.say('Please provide the server name to be set in the apache file httpd.conf (i.e. localhost or www.mysite.com):')
  set :passenger_server_name, 'localhost'# Capistrano::CLI.ui.ask('> server name: ')
  set :passenger_document_root, "#{app_root_path}/current/public"

# server setup tasks
  namespace :server_setup do
    task :default do
      #create_app_user
      #create_app_directory
      create_app_database
      #passenger_conf
    end

    desc 'Create the application user and assign it to its group.'
    task :create_app_user, :roles => :app do
      sudo "useradd #{app_user} --create-home" do |ch, stream, out|
        puts "     << #{out}"
      end

      sudo "passwd #{app_user}" do |ch, stream, out|
        puts "     << #{out}"
        sleep(1)
        if out =~ /Enter new UNIX password:/
          ch.send_data "#{app_user_password}" + "\n"
        elsif out =~ /Retype new UNIX password:/
          ch.send_data "#{app_user_password}" + "\n"
        else
          ch.send_data "\n"
        end
      end

      sudo "adduser #{app_user} #{app_user_group}" do |ch, stream, out|
        puts "     << #{out}"
      end
    end

    desc 'Create the application directory, change its owner to app user and grant the required permissions.'
    task :create_app_directory, :roles => :app do
      sudo "sh -c 'if [ ! -d #{apps_path} ]; then mkdir #{apps_path}; fi'"
      sudo "mkdir #{app_root_path}"
      sudo "chown #{app_user}:#{app_user_group} -R #{app_root_path}"
      sudo "chmod 775 -R #{app_root_path}"
    end

    desc 'Create the app production database and grant rights on it to the database user.'
    task :create_app_database, :roles => :db do
      run "mysql -u root -p" do |ch, stream, out|
        puts "     << #{out}"
        sleep(1)
        ch.send_data db_root_password + "\n"
        ch.send_data "\n"
        ch.send_data "\n"
      end
      run "create database #{application}_production;" do |ch, stream, out|
        puts "     << #{out}"
        sleep(1)
      end
      run "GRANT ALL PRIVILEGES ON #{application}_production.* TO '#{db_user}'@localhost IDENTIFIED BY '#{db_user_password}';" do |ch, stream, out|
        puts "     << #{out}"
        sleep(1)
      end
      run 'exit' do |ch, stream, out|
        puts "     << #{out}"
        sleep(1)
      end
    end

    desc 'Create Passenger configuration file'
    task :passenger_conf, :roles => :app do
      require 'erb'
      template = ERB.new(File.read('setup/templates/httpd.conf.erb'), nil, '<>')
      result = template.result(binding)
      sudo "sh -c 'if [ -f /etc/apache2/httpd.conf ]; then rm /etc/apache2/httpd.conf; fi'"
      put(result, "/home/#{user}/httpd.conf") # put do not support sudo
      sudo "mv /home/#{user}/httpd.conf /etc/apache2/httpd.conf"
      sudo "chown root:root /etc/apache2/httpd.conf"
    end
  end







