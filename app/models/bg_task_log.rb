
class BgTaskLog < ActiveRecord::Base

  def self.all(args)
    find :all, :order => 'created_at DESC', :limit => args[:limit]
  end

  def self.delete_olds(threshold)
    delete_all ['created_at < ?', threshold]
  end
end
