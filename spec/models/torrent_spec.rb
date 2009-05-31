require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Torrent do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @commenter = make_user('joe-the-commenter', @role_user)
    @rewarder  = make_user('joe-the-rewarder', @role_user)
    @uploader  = make_user('joe-the-uploader', @role_user)
    @torrent   = make_torrent(@uploader)
  end

  # main class

    # editable_by rules

      it 'should be editable only by creator or an admin_mod' do
        @torrent.editable_by?(@uploader).should be_true
        @torrent.editable_by?(@mod).should be_true
        @torrent.editable_by?(@admin).should be_true
        @torrent.editable_by?(@user).should be_false
      end

    # edition

      it 'should be edited given the valid parameters' do
        new_category = fetch_category('new_category', 'audio')
        new_format   = fetch_format('new_format', 'audio')
        new_country  = fetch_country('new_country')
        new_tag      = fetch_tag('new_tag', 'new_category')
        new_tag_two  = fetch_tag('new_tag_two', 'new_category')

        params = { :name => 'Edited Name',
                   :category_id => new_category.id,
                   :format_id => new_format.id,
                   :tags_str => 'new_tag, new_tag_two',
                   :description => 'Edited description.',
                   :year => 6666,
                   :country_id => new_country.id }

        @torrent.reload # required by some obscure reason...
        @torrent.edit params, @uploader, 'whatever reason'
        @torrent.reload

        @torrent.name.should == 'Edited Name'
        @torrent.category.should == new_category
        @torrent.format.should == new_format
        @torrent.tags.should include(new_tag)
        @torrent.tags.should include(new_tag_two)
        @torrent.description.should == 'Edited description.'
        @torrent.year.should == 6666
        @torrent.country.should == new_country
      end

    # bookmarks

      it 'should be bookmarked' do
        @torrent.bookmark_unbookmark(@user)

        Bookmark.find_by_user_id_and_torrent_id(@user, @torrent).should_not be_nil
      end

      it 'should be unbookmarked' do
        @torrent.bookmark_unbookmark(@user)
        @torrent.bookmark_unbookmark(@user)

        Bookmark.find_by_user_id_and_torrent_id(@user, @torrent).should be_nil
      end

    # new torrent

      it 'should be created receiving a torrent file' do
        c = fetch_category('music', 'audio')
        torrent_file_data = File.new(File.join(TEST_DATA_DIR, 'valid.torrent'), 'rb').read

        t = make_torrent(@uploader, nil, nil, false) # make an unsaved torrent
        t.parse_and_save(torrent_file_data, true)
        t.reload

        t.dir_name.should == 'Upload Test'
        t.piece_length.should == 65536
        t.info_hash_hex.should == '54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1'
        t.files_count.should == 3
        t.mapped_files.find_by_name_and_size('01 - Test One.mp3', 1757335).should_not be_nil
        t.size.should == t.mapped_files.inject(0) {|s, e| s + e.size}
      end

    # inactivation, activation and remotion

      it 'should be inactivated and notify' do
        @torrent.inactivate(@mod, 'whatever reason')
        @torrent.reload
        
        @torrent.should_not be_active
        
        m = Message.find_by_receiver_id_and_subject @torrent.user, I18n.t('model.torrent.notify_inactivation.subject')
        m.should_not be_nil
        m.body.should == I18n.t('model.torrent.notify_inactivation.body', :name => @torrent.name, :by => @mod.username, :reason => 'whatever reason')
      end

      it 'should be activated and notify' do
        @torrent.inactivate(@mod, 'whatever reason')
        @torrent.reload
        @torrent.activate(@mod)
        @torrent.reload

        @torrent.should be_active

        m = Message.find_by_receiver_id_and_subject @torrent.user, I18n.t('model.torrent.notify_activation.subject')
        m.should_not be_nil
        m.body.should == I18n.t('model.torrent.notify_activation.body', :name => @torrent.name, :by => @mod.username)
      end

      it 'should be destroyed and notify' do
        @torrent.destroy_with_notification(@mod, 'whatever reason')

        Torrent.find_by_id(@torrent.id).should be_nil

        m = Message.find_by_receiver_id_and_subject @torrent.user, I18n.t('model.torrent.notify_destruction.subject')
        m.should_not be_nil
        m.body.should == I18n.t('model.torrent.notify_destruction.body', :name => @torrent.name, :by => @mod.username, :reason => 'whatever reason')
      end

    # reporting

      it 'should be reportable' do
        @torrent.report @user, 'Whatever reason.', "torrents/show/#{@user.id}"
        Report.find_by_user_id_and_target_path(@user, "torrents/show/#{@user.id}").should_not be_nil
      end

    # comments

      it 'should add a comment to itself given the valid parameters' do
        comments_count = @torrent.comments_count

        @torrent.add_comment('Comment body.', @commenter)
        @torrent.reload

        c = Comment.find_by_torrent_id_and_body_and_user_id(@torrent, 'Comment body.', @commenter)
        c.should_not be_nil

        @torrent.comments_count.should == comments_count + 1
        @torrent.paginate_comments({}, {:per_page => 10}).should include(c)
      end

    # rewards

      it 'should add a reward to itself given the valid parameters' do
        rewards_count = @torrent.rewards_count

        @torrent.add_reward(12345, @rewarder)
        @torrent.reload

        r = Reward.find_by_torrent_id_and_amount_and_user_id(@torrent, 12345, @rewarder)
        r.should_not be_nil

        @torrent.rewards_count.should == rewards_count + 1
        @torrent.paginate_rewards({}, :per_page => 10).should include(r)
      end

  # tracker concern

    it 'should add a snatch to itself given the valid parameters' do
        @torrent.leechers_count = 1
        @torrent.save

        snatches_count = @torrent.snatches_count
        seeders_count = @torrent.seeders_count
        leechers_count = @torrent.leechers_count

        @torrent.add_snatch(@user)
        @torrent.reload

        s = Snatch.find_by_torrent_id_and_user_id(@torrent, @user)
        s.should_not be_nil

        @torrent.snatches_count.should == snatches_count + 1
        @torrent.seeders_count.should == seeders_count + 1
        @torrent.leechers_count.should == leechers_count - 1
        @torrent.paginate_snatches({}, :per_page => 10).should include(s)
    end
end





