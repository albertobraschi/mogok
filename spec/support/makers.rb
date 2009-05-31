
  # methods that create records using the 'machinist' gem

  # users

    def make_user(username, role, save = true)
      if save
        User.make(:username => username, :role => (role || fetch_role), :style => fetch_style)
      else
        User.make_unsaved(:username => username, :role => (role || fetch_role), :style => fetch_style)
      end
    end

    def make_system_user
      User.make(:id => 1, :username => 'system', :role => fetch_role(Role::SYSTEM), :style => fetch_style)
    end

  # torrents

    def make_torrent(user, name = nil, category = nil, save = true)
      name ||= 'Torrent Name'
      category ||= fetch_category('music', 'audio')
      if save
        Torrent.make(:user => user, :name => name, :category => category)
      else
        Torrent.make_unsaved(:user => user, :name => name, :category => category)
      end
    end

    def make_comment(torrent, commenter)
      Comment.make(:torrent => torrent, :user => commenter)
    end

    def make_reward(torrent, rewarder, amount)
      Reward.make(:torrent => torrent, :user => rewarder, :amount => amount)
    end

  # forums

    def make_forum(name = nil)
      Forum.make(:name => name || 'Forum Name')
    end

    def make_topic(forum, creator)
      Topic.make(:forum => forum, :user => creator)
    end

    def make_post(forum, topic, creator)
      Post.make(:forum => forum, :topic => topic, :user => creator)
    end

  # invitations

    def make_invitation(inviter, email, code = nil)
      Invitation.make(:user => inviter, :email => email, :code => code || User.make_invite_code)
    end

  # messages

    def make_message(owner, receiver, sender, subject = nil, folder = nil, save = true)
      if save
        Message.make(:owner => owner, :receiver => receiver, :sender => sender, :subject => subject, :folder => folder)
      else
        Message.make_unsaved(:owner => owner, :receiver => receiver, :sender => sender, :subject => subject, :folder => folder)
      end
    end

  # login

    def make_login_attempt(ip, attempts_count = 0)
      LoginAttempt.make(:ip => ip, :attempts_count => attempts_count)
    end

    def make_password_recovery(user, code)
      PasswordRecovery.make(:user => user, :code => code)
    end

  # reports

    def make_report(reporter)
      Report.make(:user => reporter)
    end

  # wishes

    def make_wish(wisher, name = nil, category = nil)
      name ||= 'Wish Name'
      Wish.make(:user => wisher, :name => name, :category => category || fetch_category('music', 'audio'))
    end

    def make_wish_bounty(wish, bounter, amount)
      WishBounty.make(:wish => wish, :user => bounter, :amount => amount)
    end

    def make_wish_comment(wish, commenter)
      WishComment.make(:wish => wish, :user => commenter)
    end

  # app params

    def make_app_param(name, value)
      AppParam.make(:name => name, :value => value)
    end

  # peers

    def make_peer(t, u, ip, port, seeder)
      Peer.make(:torrent => t, :user => u, :ip => ip, :port => port, :seeder => seeder, :peer_conn => fetch_peer_conn(ip, port))
    end








  