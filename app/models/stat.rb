
class Stat < ActiveRecord::Base

  before_save :marshal_attributes

  def top_contributors_list
    Marshal.load(self.top_contributors.unpack('m')[0]) if self.top_contributors
  end

  def top_uploaders_list
    Marshal.load(self.top_uploaders.unpack('m')[0]) if self.top_uploaders
  end

  def self.newest
    find :first, :order => 'id DESC'
  end

  def self.paginate(params, args)
    super :order => 'created_at DESC', :page => params[:page], :per_page => args[:per_page]
  end

  private

    def marshal_attributes
      self.top_contributors = self.top_contributors.blank? ? nil : [Marshal.dump(self.top_contributors)].pack('m*')
      self.top_uploaders = self.top_uploaders.blank? ? nil : [Marshal.dump(self.top_uploaders)].pack('m*')
    end
end
