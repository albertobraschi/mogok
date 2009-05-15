 
module BgTasks

  module Utils

    protected

      def fetch_tasks(config)
        tasks = BgTask.all
        tasks = load_tasks config if tasks.blank?
        tasks
      end

      def load_tasks(config)
        tasks = []
        unless config[:bg_tasks].blank?
          config[:bg_tasks].each do |bg_task|
            t = BgTask.new(:name => bg_task[:name], :interval_minutes => bg_task[:interval_minutes])
            t.class_name = bg_task[:class_name]
            t.save
            tasks << t
          end
        end
        tasks
      end

      def reload_tasks(config)
        BgTask.delete_all
        load_tasks config
      end

      def exec_task(bg_task, config, logger = nil, force = false)
        if bg_task.class_name =~ /^BgTasks::[A-Za-z]+\Z/
          Kernel.eval(bg_task.class_name).new.exec bg_task, config, logger, force
        end
      end

      def app_log(text, admin = false)
        Log.create text, admin
      end

      def log_task_error(e, task_name)
        ErrorLog.create :created_at => Time.now,
                        :message => "Task: #{task_name}\n Error: #{e.class}\n Message: #{e.clean_message}",
                        :location => e.backtrace[0, 15].join("\n")
      end
  end
end






