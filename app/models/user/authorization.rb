
class User

  # role concern

  def system_user?
    self.role.system?
  end

  def owner?
    self.role.owner?
  end

  def admin?
    self.role.admin?
  end

  def admin_mod?
    self.role.admin? || self.role.mod?
  end

  def mod?
    self.role.mod?
  end

  def has_ticket?(ticket)
    self.role.has_ticket?(ticket) || (self.tickets && self.tickets.split(' ').include?(ticket.to_s))
  end  
end












