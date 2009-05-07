
class ErrorLog < ActiveRecord::Base

  def self.all(args)
    find :all, :order => 'created_at DESC', :limit => args[:limit]
  end
end
