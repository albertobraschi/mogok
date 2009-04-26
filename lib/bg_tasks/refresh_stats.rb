
module BgTasks

  class RefreshStats    
    include BgTasks::Utils

    def exec(bg_task, config, logger = nil, force = false)
      exec_begin_at = Time.now

      unless force
        exec_now = bg_task.next_exec_at && bg_task.next_exec_at < Time.now
        if exec_now || bg_task.next_exec_at.blank?
          bg_task.next_exec_at = Time.now + bg_task.interval_minutes.minutes
          bg_task.save
          logger.debug ":-) TASK #{bg_task.name} scheduled to #{bg_task.next_exec_at.to_s :db}" if logger
        end
      end

      stats_not_found = false

      if force || stats_not_found || exec_now
        begin
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
          stat.top_uploaders = User.find :all, :order => 'uploaded DESC', :conditions => 'uploaded > 0', :limit => 10          

          # top contributors (who uploaded more torrents)
          stat.top_contributors = []
          q = 'SELECT user_id, COUNT(*) AS uploads FROM torrents WHERE user_id IS NOT NULL GROUP BY user_id ORDER BY uploads DESC LIMIT 10'
          result = Torrent.connection.select_all q
          result.each {|r| stat.top_contributors << {:user => User.find(r['user_id']), :torrents => r['uploads']} }

          stat.save
          logger.debug ':-) TASK SiteStats successfully executed' if logger
          status = 'OK'
        rescue => e
          status = 'FAILED'
          log_error e, bg_task.name
          logger.error ":-( TASK #{bg_task.name} ERROR: #{e.message}" if logger
          raise e if force
        end
      end
      if status && !force
        log_task_exec bg_task.name, status, exec_begin_at, Time.now, bg_task.next_exec_at
      end
    end

    private

    def ratio(uploaded, downloaded)
      return 0 if uploaded == 0 || downloaded == 0
      sprintf "%.3f", (uploaded / downloaded.to_f)
    end
  end
end
