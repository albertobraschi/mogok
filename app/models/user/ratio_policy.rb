
class User

  # ratio policy concern

  def under_ratio_watch?
    defective? && self.ratio_watch_until
  end

  # Put this user under ratio watch until the specified date
  def start_ratio_watch(watch_until)
    User.transaction do
      self.role = Role.find_by_name(Role::DEFECTIVE)
      self.ratio_watch_until = watch_until
      save!
      notify_ratio_watch
    end
  end

  # End this user ratio watch
  def end_ratio_watch
    self.role = Role.find_by_name(Role::USER)
    self.ratio_watch_until = nil
    save!
  end

  # Assign role 'defective' to all users whose downloaded data amount is between the specified
  # min and max and have ratio below the minimum. Also sets a date as the limit for the users to
  # fix their ratio.
  def self.start_ratio_watch(min_downloaded, max_downloaded, min_ratio, watch_until)
    q, h = '', {}
    q << 'active = true '
    q << 'AND ratio_watch_until IS NULL '
    q << 'AND downloaded > :min_downloaded '
    q << 'AND downloaded < :max_downloaded ' if max_downloaded
    q << 'AND ratio < :min_ratio '    
    h[:min_downloaded] = min_downloaded
    h[:max_downloaded] = max_downloaded if max_downloaded
    h[:min_ratio] = min_ratio

    User.find(:all, :conditions => [q, h]).each do |u|
      next if u.has_ticket?(:staff)
      u.start_ratio_watch(watch_until)
      logger.debug ":-) user #{u.username} put under ratio watch until #{watch_until}"
    end
  end

  # Search for all users under ratio watch (role is 'defective' and ratio_watch_until
  # is not null) and check if the user achieved the minimum ratio required by its downloaded data
  # amount (between the min and max). If user has the required ratio then its role is set
  # back to 'user'. If not, user is inactivated or removed from the system.
  def self.finish_ratio_watch(min_downloaded, max_downloaded, min_ratio)
    defective_role = Role.find_by_name(Role::DEFECTIVE)    

    q, h = '', {}
    q << 'active = true '
    q << 'AND role_id = :defective_role_id '
    q << 'AND ratio_watch_until IS NOT NULL '
    q << 'AND ratio_watch_until < :now '
    q << 'AND downloaded > :min_downloaded '    
    q << 'AND downloaded < :max_downloaded ' if max_downloaded
    h[:defective_role_id] = defective_role.id
    h[:now] = Time.now
    h[:min_downloaded] = min_downloaded
    h[:max_downloaded] = max_downloaded if max_downloaded

    User.find(:all, :conditions => [q, h]).each do |u|
      if u.ratio > min_ratio # user managed to fix its ratio
        u.end_ratio_watch
      else
        if u.torrents.count > 0 # if user has at least one torrent
          u.inactivate 
          Log.create "User #{u.username} inactivated by system (ratio rules)."
          logger.debug ":-) user #{u.username} inactivated"
        else
          u.destroy
          Log.create "User #{u.username} removed by system (ratio rules)."
          logger.debug ":-) user #{u.username} destroyed"
        end
      end
    end
  end

  # Apply rules for promotion and demotion, based on the user's uploaded data amount and ratio.
  def self.promote_demote_by_data_transfer(lower_role_name, higher_role_name, min_uploaded, min_ratio)

    lower_role = Role.find_by_name(lower_role_name)
    higher_role = Role.find_by_name(higher_role_name)

    # users promotion
    conditions = ['active = true AND role_id = ? AND uploaded > ? AND ratio > ?',
                  lower_role.id, min_uploaded, min_ratio]

    User.find(:all, :conditions => conditions).each do |u|
      u.role = higher_role
      u.save
      Log.create "User #{u.username} was promoted to #{higher_role.description}."
      logger.debug ":-) user #{u.username} promoted from #{lower_role.name} to #{higher_role.name}"
    end

    # users demotion
    conditions = ['active = true AND role_id = ? AND (uploaded < ? OR ratio < ?)',
                  higher_role.id, min_uploaded, min_ratio]

    User.find(:all, :conditions => conditions).each do |u|
      u.role = lower_role
      u.save
      logger.debug ":-) user #{u.username} demoted from #{higher_role.name} to #{lower_role.name}"
    end
  end
end



