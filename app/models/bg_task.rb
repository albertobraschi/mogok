
class BgTask < ActiveRecord::Base

  attr_protected :name, :class_name

  has_many :bg_task_params, :dependent => :destroy

  validates_presence_of :name, :class_name

  def exec_now?
    @exec_now
  end

  def params_hash
    @params_hash || load_params_hash
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

  def add_param(name, value)
    self.bg_task_params << BgTaskParam.new(:name => name, :value => YAML.dump(value))
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
