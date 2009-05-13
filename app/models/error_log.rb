
class ErrorLog < ActiveRecord::Base

  before_save :trim_attributes

  def self.all(args)
    find :all, :order => 'created_at DESC', :limit => args[:limit]
  end

  def self.has?
    !find(:first).blank?
  end

  protected

  def trim_attributes
    self.message = self.message[0, 1000] if self.message
    self.location = self.location[0, 5000] if self.location
  end
end
