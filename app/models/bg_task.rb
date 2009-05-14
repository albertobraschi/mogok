
class BgTask < ActiveRecord::Base

  attr_protected :class_name

  validates_presence_of :name, :class_name

  def exec_now?
    @exec_now
  end

  def schedule(logger = nil)
    @exec_now = self.next_exec_at && self.next_exec_at < Time.now
    
    if exec_now? || self.next_exec_at.blank?
      if self.interval_minutes
        self.next_exec_at = Time.now + self.interval_minutes.minutes
        logger.debug ":-) TASK #{self.name} scheduled to #{I18n.l self.next_exec_at, :format => :db}" if logger
        save
      end
    end
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

  def self.all
    find :all, :order => 'name'
  end
end
