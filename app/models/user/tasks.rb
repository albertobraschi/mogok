
class User

  # tasks concern

  def self.destroy_or_inactivate_by_absense(threshold)

    absents = find :all, :conditions => ['last_request_at < ? AND active = TRUE', threshold]

    absents.each do |u|
      next if u.has_ticket?(:staff) || u.has_ticket?(:perpetual)
      if u.torrents.count > 0
        u.inactivate # inactivate if user has at least one torrent
        Log.create "User #{u.username} inactivated by system (unused account)."
      else
        u.destroy
        Log.create "User #{u.username} removed by system (unused account)."
      end
    end
  end
end


