 
module BgTasks
  
  class Dispatcher
    include BgTasks::Utils

    def self.exec(config, logger = nil, env = nil)
      Dispatcher.new.exec config, logger, env
    end

    def exec(config, logger = nil, env = nil)
      begin        
        exec_tasks config, logger, env
      rescue => e
        log_error e, 'BgTasks::Dispatcher'
      end
    end

    private

    def exec_tasks(config, logger = nil, env = nil)
      tasks = BgTasks::Utils.fetch_tasks config
      unless tasks.blank?
        log_task_exec "Dispatcher [ENV:#{env}]"
        tasks.each do |t|
          eval(t.class_name).new.exec(t, config, logger) if t.active? && t.interval_minutes
        end
      else
        log_task_exec "Dispatcher [ENV:#{env}]", 'NO TASKS FOUND'
      end
    end
  end
end












