 
module BgTasks

  module Utils

    module_function

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

    def log(text, admin = false)
      Log.create :created_at => Time.now, :body => text, :admin => admin
    end

    def log_error(e, task_name)
      ErrorLog.create :created_at => Time.now,
                      :message => "Task: #{task_name}\n Error: #{e.class}\n Message: #{e.clean_message}",
                      :location => e.backtrace[0, 15].join("\n")
    end
  end
end






