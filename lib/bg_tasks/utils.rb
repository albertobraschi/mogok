 
module BgTasks

  module Utils

    module_function

    def fetch_tasks(config)
      tasks = BgTask.all
      tasks = load_tasks config if tasks.blank?
      tasks
    end

    def load_tasks(config)
      a = []
      unless config[:bg_tasks].blank?
        config[:bg_tasks].each do |bg_task|
          t = BgTask.new(:name => bg_task[:name], :interval_minutes => bg_task[:interval_minutes])
          t.class_name = bg_task[:class_name]
          t.save
          a << t
        end
      end
      a
    end

    def reload_tasks(config)
      BgTask.delete_all
      load_tasks config
    end

    def log(text, admin = false)
      Log.create :created_at => Time.now, :body => text, :admin => admin
    end

    def log_error(e, task_name)
      if ErrorLog.count(:all) < 50
        ErrorLog.create :created_at => Time.now,
                        :message => "Task: #{task_name}\n Error: #{e.class.name}\n Message: #{e.clean_message[0, 500]}",
                        :location => e.backtrace[0, 20].join("\n")[0, 2000]
      end
    end

    def exec_task(bg_task, config, logger = nil, force = false)
      if bg_task.class_name =~ /^BgTasks::[A-Za-z]+\Z/
        Kernel.eval(bg_task.class_name).new.exec bg_task, config, logger, force
      end
    end
  end
end






