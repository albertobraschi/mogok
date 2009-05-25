
module NavigationHelpers

  def path_to(page_name)

    case page_name
      
      when /the homepage/i
        root_path

      when /the login page/i
        login_path

      when /the new message page/i
        messages_path(:action => 'new')

      when /^the messenger page for folder "(.*)"$/i
        messages_path(:action => 'folder', :id => $1)

      when /the password recovery page/i
        password_recovery_path

      when /^the change password page with recovery code "(.*)"$/i
        change_password_path(:recovery_code => $1)

      when /the signup page without invite code/i
        signup_path

      when /^the signup page with invite code "(.*)"$/i
        signup_with_invite_path(:invite_code => $1)

      when /^the torrent details page for torrent "(.*)"$/i
        torrents_path(:action => 'show', :id => Torrent.find_by_name($1))

      when /the torrent upload page/i
        upload_path

      when /the new wish page/i
        wishes_path(:action => 'new')

      when /^the wish details page for wish "(.*)"$/i
        wishes_path(:action => 'show', :id => Wish.find_by_name($1))

      when /^the wish filling page for wish "(.*)"$/i
        wishes_path(:action => 'fill', :id => Wish.find_by_name($1))

      when /the invitations page/i
        invitations_path

      when /^the user details page for user "(.*)"$/i
        users_path(:action => 'show', :id => User.find_by_username($1))

      when /^the forum page for forum "(.*)"$/i
        forums_path(:action => 'show', :id => Forum.find_by_name($1))

      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n"
    end
  end
end

World(NavigationHelpers)
