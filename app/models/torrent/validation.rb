
class Torrent

  # validation concern

  MAX_TAGS = 4

  def self.t_error(field, key, args = {})
    I18n.t("model.torrent.errors.#{field}.#{key}", args)
  end

  validates_uniqueness_of :info_hash, :on => :create, :message => t_error('info_hash', 'taken')
  validates_format_of :year, :with => /\d{4}/, :message => t_error('year', 'invalid'), :allow_blank => true
  validates_presence_of :name
  validates_presence_of :category_id

  validate :validate_tags

  def add_error(field, key, args = {})
    errors.add field, self.class.t_error(field.to_s, key, args)
  end

  private

    def validate_tags
      add_error(:tags, 'max', :max => MAX_TAGS) if self.tags.size > MAX_TAGS
    end
end
