 
module BgTasks
  
  class Dispatcher
    include BgTasks::Utils

    def self.exec(logger = nil)
      new.exec_all logger
    end

    def exec_all(logger = nil)
      begin
        tasks = fetch_tasks
        unless tasks.blank?
          BgTask.log_exec 'dispatcher'
          tasks.each {|t| t.exec(logger) if t.active? && t.interval_minutes }
        else
          BgTask.log_exec 'dispatcher', 'NO TASKS FOUND'
        end
      rescue => e
        BgTask.log_task_error e, 'BgTasks::Dispatcher'
      end
    end
  end
end












