
class Wish  

  # moderation concern

  def approve
    Wish.transaction do
      self.pending = false
      self.filled = true
      self.comments_locked = true
      self.save

      self.filler.lock!
      self.filler.uploaded += self.total_bounty
      self.filler.save

      log_approval
      notify_approval
    end
  end

  def reject(rejecter, reason)
    Wish.transaction do
      notify_rejection rejecter, reason

      self.pending = false
      self.torrent_id = nil
      self.filler_id = nil
      self.filled_at = nil
      save     
    end
  end

  def self.has_pending?
    !find(:first, :conditions => {:pending => true}).blank?
  end
end