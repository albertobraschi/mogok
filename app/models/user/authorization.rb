
class User

  # authorization concern

  def system?
    self.role.system?
  end

  def owner?
    self.role.owner?
  end

  def admin?
    self.role.admin?
  end

  def mod?
    self.role.mod?
  end

  def admin_mod?
    admin? || mod?
  end

  def defective?
    self.role.defective?
  end

  def has_ticket?(ticket)
    self.role.has_ticket?(ticket) || (self.tickets && self.tickets.split(' ').include?(ticket.to_s))
  end

  def add_ticket!(ticket)
    update_attribute :tickets, self.tickets.blank? ? ticket.to_s : "#{self.tickets} #{ticket}"
  end

  def remove_ticket!(ticket)
    update_attribute :tickets, self.tickets.gsub(ticket.to_s, '').split
  end
end












