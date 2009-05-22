
class ErrorLog < ActiveRecord::Base

  before_save :trim_attributes

  def self.all(args)
    find :all, :order => 'created_at DESC', :limit => args[:limit]
  end

  def self.has?
    !find(:first).blank?
  end

  def self.create(message, location)
    super :message => message, :location => location
  end

  def self.log_error(e)
    message =  "Error: #{e.class}\n"
    message << "Message: #{e.clean_message}"
    
    location = e.backtrace[0, 15].join("\n")

    create message, location
  end

  private

    def trim_attributes
      self.message = self.message[0, 1000] if self.message
      self.location = self.location[0, 5000] if self.location
    end
end
