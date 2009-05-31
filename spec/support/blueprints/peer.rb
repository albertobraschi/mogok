
Peer.blueprint do
  leftt { seeder ? 0 : torrent.size }
  started_at Time.now
  last_action_at Time.now
end






