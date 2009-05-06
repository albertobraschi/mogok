
class Stat < ActiveRecord::Base

  def before_save
    self.top_contributors = self.top_contributors.blank? ? nil : [Marshal.dump(self.top_contributors)].pack('m*')
    self.top_uploaders = self.top_uploaders.blank? ? nil : [Marshal.dump(self.top_uploaders)].pack('m*')
  end

  def top_contributors_list
    Marshal.load(self.top_contributors.unpack('m')[0]) if self.top_contributors
  end

  def top_uploaders_list
    Marshal.load(self.top_uploaders.unpack('m')[0]) if self.top_uploaders
  end

  def self.first
    find :first, :order => 'id DESC'
  end

  def self.paginate(params, *args)
    options = args.pop
    super :order => 'created_at DESC', :page => current_page(params[:page]), :per_page => options[:per_page]
  end
end
