
class AppParam < ActiveRecord::Base

  def validate
    unless AppParam.valid_param_value?(self.value)
      errors.add :value, 'invalid value'
    end
  end

  def self.load
    h = {}
    find(:all).each do |p|
      h[p.name.to_sym] = eval(p.value) if AppParam.valid_param_value?(p.value) # also checks when loading
    end
    h
  end

  def self.get_value(param_name)
    eval(AppParam.find_by_name(param_name.to_s).value)
  end

  private

  def self.valid_param_value?(v)
    if v != 'true' && v != 'false'
      begin
        Integer(v)
      rescue
        return false # only 'true', 'false' or a number are accepted as the param value
      end      
    end
    true
  end
end
