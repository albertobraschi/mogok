
class Report < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :user
  belongs_to :handler, :class_name => 'User', :foreign_key => 'handler_id'

  before_save :trim_reason

  def self.all
    find :all, :order => 'created_at DESC'
  end

  def self.create(target, target_path, reporter, reason)
    super :label => report_label(target),
          :target_path => target_path,
          :user => reporter,
          :reason => reason
  end

  def has_open?
    !find(:first, :conditions => {:handler_id => nil}).blank?
  end

  private

    def trim_reason
      self.reason = self.reason[0, 200]
    end

    def self.report_label(obj)
      "#{obj.class.name.downcase} [#{obj.id}]"
    end
end
