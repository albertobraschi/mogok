
class AppParam < ActiveRecord::Base

  validate :validate_value

  def self.load
    h = {}
    find(:all).each {|p| h[p.name.to_sym] = parse_value(p.value) }
    h
  end

  def self.get_value(param_name)
    parse_value find_by_name(param_name).value
  end

  private

  def validate_value
    begin
      self.class.parse_value self.value
    rescue
      errors.add :value, 'value not supported'
    end
  end

  def self.parse_value(v)
    case v
      when 'true'
        return true
      when 'false'
        return false
      else
        return Integer(v) # error unless 'true', 'false' or a numeric string
      end
  end
end
