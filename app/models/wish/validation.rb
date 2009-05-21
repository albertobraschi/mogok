
class Wish

  # validation concern

  def self.t_error(field, key, args = {})
    I18n.t("model.wish.errors.#{field}.#{key}", args)
  end

  validates_format_of :year, :with => /\d{4}/, :message => t_error('year', 'invalid'), :allow_blank => true
  validates_presence_of :name
  validates_presence_of :category_id

  def add_error(field, key, args = {})
    errors.add field, self.class.t_error(field.to_s, key, args)
  end
end
