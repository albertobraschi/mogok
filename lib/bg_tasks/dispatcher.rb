 
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
        log_task_error e, 'BgTasks::Dispatcher'
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
  end
end












