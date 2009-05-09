
class Role < ActiveRecord::Base
  has_many :users

  attr_protected :name

  validates_presence_of :name, :css_class, :description
  validates_uniqueness_of :name, :case_sensitive => false

  SYSTEM, OWNER, ADMINISTRATOR, MODERATOR, USER = 'system', 'owner', 'admin', 'mod', 'user'

  def self.all_for_search
    find(:all).delete_if {|r| r.system? }
  end

  def self.all_for_user_edition(editor)
    if editor.owner?
      find(:all).delete_if {|r| r.system? }
    elsif editor.admin?
      find(:all).delete_if {|r| r.reserved? }
    end
  end

  def has_ticket?(ticket)
    self.tickets && self.tickets.split(' ').include?(ticket.to_s)
  end

  def reserved?
    true if [SYSTEM, OWNER, ADMINISTRATOR].include? self.name
  end

  def default?
    true if [SYSTEM, OWNER, ADMINISTRATOR, MODERATOR, USER].include? self.name
  end

  def system?
    is? SYSTEM
  end

  def owner?
    (is? OWNER) || system?
  end

  def admin?
    (is? ADMINISTRATOR) || owner?
  end

  def mod?
    is? MODERATOR
  end

  def is?(role_name)
     self.name == role_name
  end
end
