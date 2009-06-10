 
module BgTasks

  module Utils

    protected

      # Retrieve the tasks from the database or load them from the config file.
      def fetch_tasks
        tasks = BgTask.all
        tasks = load_tasks if tasks.nil? || tasks.empty?
        tasks
      end

      def reload_tasks
        BgTask.destroy_all
        load_tasks
      end

      # Load the bg_tasks configuration file and create records in the database
      # for each task and its parameters.
      def load_tasks
        config = open(File.join(RAILS_ROOT, 'config/bg_tasks.yml')) {|f| YAML.load(f)[RAILS_ENV] }
        config.symbolize_keys!

        unless config.blank?
          config.each do |task_name, task_properties|
            task_properties.symbolize_keys!
            
            t = BgTask.new
            t.name = task_name.to_s
            t.interval_minutes = task_properties[:interval_minutes]            
            unless task_properties[:params].blank?
              task_properties[:params].each do |param_name, param_value|
                t.add_param param_name, param_value
              end
            end
            t.save
          end
        end
        BgTask.all
      end
  end
end






