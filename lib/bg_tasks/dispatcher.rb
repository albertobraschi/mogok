 
module BgTasks
  
  class Dispatcher
    include BgTasks::Utils

    def self.exec(logger = nil, env = nil)
      new.exec_all logger, env
    end

    def exec_all(logger = nil, env = nil)
      begin        
        do_exec_all logger, env
      rescue => e
        log_task_error e, 'BgTasks::Dispatcher'
      end
    end

    private

      def do_exec_all(logger = nil, env = nil)
        tasks = fetch_tasks
        unless tasks.blank?
          BgTask.log_exec "dispatcher[#{env}]"
          tasks.each do |t|
            exec_task(t, logger) if t.active? && t.interval_minutes
          end
        else
          BgTask.log_exec "dispatcher[#{env}]", 'NO TASKS FOUND'
        end
      end
  end
end












