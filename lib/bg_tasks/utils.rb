 
module BgTasks

  module Utils

    def self.fetch_tasks(config)
      tasks = BgTask.find :all, :order => 'name'
      tasks = load_tasks config if tasks.blank?
      tasks
    end

    def self.load_tasks(config)
      a = []
      tasks = config[:bg_tasks] || []
      tasks.each do |t|
        a << BgTask.create(:name => t[:name], :class_name => t[:class_name], :interval_minutes => t[:interval_minutes])
      end
      a
    end

    def self.reload_tasks(config)
      BgTask.delete_all
      load_tasks config
    end

    def self.exec_task(bg_task, config, logger)
      Kernel.eval(bg_task.class_name).new.exec bg_task, config, logger, true
    end

    def log(text, admin = false)
      Log.create :created_at => Time.now, :body => text, :admin => admin
    end

    def log_task_exec(task, status = nil, exec_begin = nil, exec_end_at = nil, next_exec_at = nil)
      BgTaskLog.create :created_at => Time.now,
                       :task => task,
                       :exec_begin_at => exec_begin,
                       :exec_end_at => exec_end_at,
                       :next_exec_at => next_exec_at,
                       :status => status
    end

    def log_error(e, task_name)
      if ErrorLog.count(:all) < 50
        ErrorLog.create :created_at => Time.now,
                        :message => "Task: #{task_name}\n Error: #{e.class.name}\n Message: #{e.clean_message[0, 500]}",
                        :location => e.backtrace[0, 20].join("\n")[0, 2000]
      end
    end
  end
end
