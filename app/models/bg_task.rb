
class BgTask < ActiveRecord::Base
  concerns :cleanup, :cleanup_peers, :promote_demote, :ratio_watch, :refresh_stats
  
  attr_protected :name

  has_many :bg_task_params, :dependent => :destroy

  validates_presence_of :name

  def exec(logger = nil, force = false)
    begin_at = Time.now

    schedule(logger) unless force

    if force || exec_now?
      begin

        self.class.send(self.name, params_hash) # invoke class method with the task's name
        
        status = 'OK'
        logger.debug ":-) task #{self.name} successfully executed" if logger
      rescue => e
        status = 'FAILED'
        self.class.log_task_error e, self.name
        logger.error ":-( task #{self.name} error: #{e.message}" if logger
        raise e if force
      end
      log_exec(status, begin_at, Time.now) unless force
    end
  end

  def exec_now?
    @exec_now
  end

  def params_hash
    @params_hash || load_params_hash
  end

  def schedule(logger = nil)
    @exec_now = self.next_exec_at && self.next_exec_at < Time.now
    
    if @exec_now || self.next_exec_at.blank?
      if self.interval_minutes
        self.next_exec_at = Time.now + self.interval_minutes.minutes
        logger.debug ":-) TASK #{self.name} scheduled to #{self.next_exec_at}" if logger
        save
      end
    end
  end

  def add_param(name, value)
    self.bg_task_params << BgTaskParam.new(:name => name, :value => YAML.dump(value))
  end

  def self.all
    find :all, :order => 'name'
  end

  def self.log_task_error(e, task_name)
    message = "Task: #{task_name}\n Error: #{e.class}\n Message: #{e.clean_message}"
    location = e.backtrace[0, 15].join("\n")
    ErrorLog.create message, location
  end

  def log_exec(status = nil, begin_at = nil, end_at = nil)
    self.class.log_exec self.name, status, begin_at, end_at, self.next_exec_at
  end

  def self.log_exec(task, status = nil, begin_at = nil, end_at = nil, next_at = nil)
    BgTaskLog.create :task => task,
                     :exec_begin_at => begin_at,
                     :exec_end_at => end_at,
                     :next_exec_at => next_at,
                     :status => status
  end

  def self.app_log(text, admin = false)
    Log.create text, admin
  end

  private

    def load_params_hash
      h = {}
      unless self.bg_task_params.blank?
        self.bg_task_params.each do |p|
          h[p.name.to_sym] = YAML.load(p.value)
        end
      end
      @params_hash = h
    end
end
