require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Wish do
  before(:each) do
    fetch_system_user
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @user = fetch_user 'joe-the-user'
    @wisher = fetch_user 'joe-the-wisher'
    @commenter = fetch_user 'joe-the-commenter'
    @bounter = fetch_user 'joe-the-bounter'
    @another_bounter = fetch_user 'joe-the-bounter_two'
    @torrent = fetch_torrent('Joe The Owners Torrent', 'joe-the-owner')    
    
    @wish = fetch_wish('Joe The Wishers Wish', 'joe-the-wisher')    
  end

  it 'should be editable by creator or admin_mod if open or only by admin_mod otherwise' do
    @wish.open?.should be_true
    @wish.editable_by?(@wisher).should be_true
    @wish.editable_by?(@user).should be_false
    @wish.editable_by?(@moderator).should be_true

    @wish.pending = true

    @wish.open?.should be_false
    @wish.editable_by?(@wisher).should be_false
    @wish.editable_by?(@user).should be_false
    @wish.editable_by?(@moderator).should be_true
  end

  it 'should be edited given the valid parameters' do
    new_category = fetch_category('new_category', 'audio')
    new_format   = fetch_format('new_format', 'audio')
    new_country  = fetch_country('new_country')

    params = { :name => 'Edited Name',
               :category_id => new_category.id,
               :format_id => new_format.id,
               :description => 'Edited description.',
               :year => 6666,
               :country_id => new_country.id }
             
    @wish.reload # required by some obscure reason...
    @wish.edit params
    @wish.reload
    
    @wish.name.should == 'Edited Name'
    @wish.category.should == new_category # for some reason category is not updated, works perfectly in the controller though
    @wish.format.should == new_format
    @wish.description.should == 'Edited description.'
    @wish.year.should == 6666
    @wish.country.should == new_country
  end

  it 'should be reportable' do
    @wish.report @user, 'Whatever reason.', "wishes/show/#{@wish.id}"
    Report.find_by_user_id_and_target_path(@user, "wishes/show/#{@wish.id}").should_not be_nil
  end

  it 'should add a comment to itself given the valid parameters' do
    comments_count = @wish.comments_count

    @wish.add_comment('Comment body.', @commenter)
    @wish.reload

    c = WishComment.find_by_wish_id_and_body_and_user_id(@wish, 'Comment body.', @commenter)
    c.should_not be_nil
    
    @wish.comments_count.should == comments_count + 1
    @wish.paginate_comments({}, {:per_page => 10}).should include(c)
  end

  it 'should add a bounty to itself given the valid parameters' do
    @wish.add_bounty(12345, @bounter)
    @wish.reload

    b = WishBounty.find_by_wish_id_and_amount_and_user_id(@wish, 12345, @bounter)
    b.should_not be_nil
    @wish.paginate_bounties({}, :per_page => 10).should include(b)
  end

  it 'should be open if not pending or filled' do
    @wish.should be_open

    @wish.pending = true
    @wish.should_not be_open

    @wish.pending = false
    @wish.filled = true
    @wish.should_not be_open
  end

  it 'should be fillable with a torrent and remain pending until moderation' do
    @wish.fill @torrent
    @wish.reload
    
    @wish.should be_pending
    @wish.torrent.should == @torrent
    @wish.filler.should == @torrent.user
    @wish.filled_at.should be_instance_of(Time)
  end

  it 'should have its filling approved, credit its bounty to filler and notify users' do
    filler_upload_credit = @torrent.user.uploaded

    @wish.add_bounty(12345, @bounter)
    @wish.reload
    @wish.add_bounty(54321, @another_bounter)
    @wish.reload
    
    @wish.fill @torrent
    @wish.reload
    
    @wish.approve
    @wish.reload
    @torrent.user.reload

    # wish filling approved?    
    @wish.should_not be_pending
    @wish.should be_filled
    @wish.comments_locked.should be_true

    # bounty credited to filler?    
    @torrent.user.uploaded.should == filler_upload_credit + @wish.total_bounty

    # filler notified?
    m = Message.find_by_receiver_id_and_subject @torrent.user, I18n.t('model.wish.notify_approval.filler_subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_approval.filler_body_with_amount', :name => @wish.name)

    # wisher notified?
    m = Message.find_by_receiver_id_and_subject @wisher, I18n.t('model.wish.notify_approval.wisher_subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_approval.wisher_body', :name => @wish.name, :by => @torrent.user.username)

    # bounters notified?
    m = Message.find_by_receiver_id_and_subject @bounter, I18n.t('model.wish.notify_approval.bounter_subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_approval.bounter_body', :name => @wish.name, :by => @torrent.user.username)

    m = Message.find_by_receiver_id_and_subject @another_bounter, I18n.t('model.wish.notify_approval.bounter_subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_approval.bounter_body', :name => @wish.name, :by => @torrent.user.username)
  end

  it 'should have its filling rejected and notify filler' do
    @wish.fill @torrent
    @wish.reload

    @wish.reject @moderator, 'whatever reason'
    @wish.reload

    @wish.should_not be_pending
    @wish.should_not be_filled
    @wish.torrent.should be_nil
    @wish.filler.should be_nil
    @wish.filled_at.should be_nil

    # filler notified?
    m = Message.find_by_receiver_id_and_subject @torrent.user, I18n.t('model.wish.notify_rejection.subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_rejection.body', :name => @wish.name, :by => @moderator.username, :reason => 'whatever reason')
  end

  it 'should notify its destruction when destroyed by a moderator' do
    @wish.fill @torrent
    @wish.reload
    
    @wish.destroy_with_notification @moderator, 'whatever reason'

    # wish deleted?
    Wish.find_by_id(@wish.id).should be_nil

    # wisher notified?
    m = Message.find_by_receiver_id_and_subject @wisher, I18n.t('model.wish.notify_destruction.subject')
    m.should_not be_nil
    m.body.should == I18n.t('model.wish.notify_destruction.body', :name => @wish.name, :by => @moderator.username, :reason => 'whatever reason')
  end
end

