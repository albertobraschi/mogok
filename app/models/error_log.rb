
class ErrorLog < ActiveRecord::Base

  def self.all(*args)
    options = args.pop
    find :all, :order => 'created_at DESC', :limit => options[:limit]
  end
end
