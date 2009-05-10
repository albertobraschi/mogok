
class ErrorLog < ActiveRecord::Base

  def before_save
    self.message = self.message[0, 1000] if self.message
    self.location = self.location[0, 5000] if self.location
  end

  def self.all(args)
    find :all, :order => 'created_at DESC', :limit => args[:limit]
  end
end
