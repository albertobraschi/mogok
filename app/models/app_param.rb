
class AppParam < ActiveRecord::Base

  def value_object
    YAML.load(self.value)
  end

  def self.params_hash
    h = {}
    find(:all).each {|p| h[p.name.to_sym] = YAML.load(p.value) }
    h
  end
end
