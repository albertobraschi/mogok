
Factory.define :peer do |p|
  p.leftt {|r| r.seeder? ? 0 : r.torrent.size }
  p.started_at Time.now
  p.last_action_at Time.now
end






