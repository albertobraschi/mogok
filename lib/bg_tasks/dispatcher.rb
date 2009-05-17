 
module BgTasks
  
  class Dispatcher
    include BgTasks::Utils

    def self.exec(logger = nil)
      new.exec_all logger
    end

    def exec_all(logger = nil)
      begin        
        do_exec_all logger
      rescue => e
        log_task_error e, 'BgTasks::Dispatcher'
      end
    end

    private

      def do_exec_all(logger = nil)
        tasks = fetch_tasks
        unless tasks.blank?
          BgTask.log_exec 'dispatcher'
          tasks.each do |t|
            exec_task(t, logger) if t.active? && t.interval_minutes
          end
        else
          BgTask.log_exec 'dispatcher', 'NO TASKS FOUND'
        end
      end
  end
end












