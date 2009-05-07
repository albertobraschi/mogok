
class Tag < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :torrent

  validates_presence_of :category_id, :name
  
  def to_s
    self.name
  end

  # parse a string like 'tag1, tag2' and return the tags
  # provide category_id to get only tags of a specified category
  def self.parse_tags(tags_str, category_id = nil)
    tags = []
    unless tags_str.blank?      
      a = tags_str.split(',')
      a.each {|s| s.strip!}
      a.uniq!
      a.each do |s|
        if category_id
          tag = Tag.scoped_by_category_id(category_id).find_by_name s
        else
          tag = Tag.find_by_name s
        end
        tags << tag if tag # invalid tags are silently ignored
      end
    end
    tags
  end

  def self.all(args)
    conditions = {:category_id => args[:category_id]} unless args[:category_id].blank?
    find :all, :conditions => conditions, :order => 'category_id, name'
  end
end
