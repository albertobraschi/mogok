 
module BgTasks

  module Utils

    protected

      def fetch_tasks
        tasks = BgTask.all
        tasks = load_tasks if tasks.blank?
        tasks
      end

      def load_tasks
        tasks = []
        config = open(File.join(RAILS_ROOT, 'config/bg_tasks.yml')) {|f| YAML.load(f) }
        config.symbolize_keys!

        unless config.blank?
          config.each_pair do |task_name, task_properties|
            task_properties.symbolize_keys!
            
            t = BgTask.new
            t.name = task_name.to_s
            t.interval_minutes = task_properties[:interval_minutes]            
            t.class_name = task_properties[:class_name]
            unless task_properties[:params].blank?
              task_properties[:params].each_pair do |param_name, param_value|
                t.add_param param_name, param_value
              end
            end
            t.save
            
            tasks << t
          end
        end
        tasks
      end

      def reload_tasks
        BgTask.destroy_all
        load_tasks
      end

      def exec_task(bg_task, logger = nil, force = false)
        if bg_task.class_name =~ /^BgTasks::[A-Za-z]+\Z/
          Kernel.eval(bg_task.class_name).new.exec bg_task, logger, force
        end
      end

      def app_log(text, admin = false)
        Log.create text, admin
      end

      def log_task_error(e, task_name)
        message = "Task: #{task_name}\n Error: #{e.class}\n Message: #{e.clean_message}"
        location = e.backtrace[0, 15].join("\n")
        ErrorLog.create message, location
      end
  end
end






