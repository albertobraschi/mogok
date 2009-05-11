 
module BgTasks
  
  class Dispatcher
    include BgTasks::Utils

    def self.exec(config, logger = nil, env = nil)
      new.exec_all config, logger, env
    end

    def exec_all(config, logger = nil, env = nil)
      begin        
        do_exec_all config, logger, env
      rescue => e
        log_error e, 'BgTasks::Dispatcher'
      end
    end

    private

    def do_exec_all(config, logger = nil, env = nil)
      tasks = fetch_tasks config
      unless tasks.blank?
        BgTask.log_exec "Dispatcher[#{env}]"
        tasks.each do |t|
          exec_task(t, config, logger) if t.active? && t.interval_minutes
        end
      else
        BgTask.log_exec "Dispatcher[#{env}]", 'NO TASKS FOUND'
      end
    end

    def exec_task(bg_task, config, logger = nil, force = false)
      if bg_task.class_name =~ /^BgTasks::[A-Za-z]+\Z/
        Kernel.eval(bg_task.class_name).new.exec bg_task, config, logger, force
      end
    end
  end
end












