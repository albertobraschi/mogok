
module BgTasks

  class RefreshStats < AbstractBgTask

    protected
    
      def do_exec(params)
        stat = Stat.new
        stat.created_at = Time.now
        stat.users_active = User.count :conditions => {:active => true}
        stat.users_inactive = User.count :conditions => {:active => false}

        stat.peers_seeding = Peer.count :conditions => {:seeder => true}
        stat.peers_leeching = Peer.count :conditions => {:seeder => false}

        stat.torrents_alive = Torrent.count :conditions => 'seeders_count > 0'
        stat.torrents_dead = Torrent.count :conditions => {:seeders_count => 0}
        stat.snatches = Torrent.sum :snatches_count

        stat.forums = Forum.count
        stat.topics = Topic.count
        stat.posts = Post.count

        stat.uploaded = User.sum :uploaded
        stat.downloaded = User.sum :downloaded
        stat.ratio = ratio stat.uploaded, stat.downloaded

        # top uploaders (who uploaded more data)
        stat.top_uploaders = User.top_uploaders :limit => 10

        # top contributors (who uploaded more torrents)
        stat.top_contributors = User.top_contributors :limit => 10

        stat.save
      end

    private

      def ratio(uploaded, downloaded)
        if uploaded == 0 || downloaded == 0
          0
        else
          sprintf "%.3f", (uploaded / downloaded.to_f)
        end
      end
  end
end
