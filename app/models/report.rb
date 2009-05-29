
class Report < ActiveRecord::Base
  strip_attributes! # strip_attributes plugin

  belongs_to :user
  belongs_to :handler, :class_name => 'User', :foreign_key => 'handler_id'

  before_save :trim_reason

  def assign_to(user)
    update_attribute :handler_id, user.id
  end

  def unassign
    update_attribute :handler_id, nil
  end

  def self.all
    find :all, :order => 'created_at DESC'
  end

  def self.create(target, reporter, reason, target_path)
    super :target_label => make_target_label(target),
          :target_path => target_path,
          :user => reporter,
          :reason => reason
  end

  def self.has_open?
    !find(:first, :conditions => {:handler_id => nil}).blank?
  end

  def self.make_target_label(obj)
    "#{obj.class.name.underscore} [#{obj.id}]"
  end

  private

    def trim_reason
      self.reason = self.reason[0, 200]
    end
end
