require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  before(:each) do
    @commenter = fetch_user 'joe-the-commenter'
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @user = fetch_user 'joe-the-user'
    @torrent = fetch_torrent('Joe The Uploaders Torrent', 'joe-the-uploader')
    @comment = Factory(:comment, :user => @commenter, :torrent => @torrent)
  end

  it 'should be editable only by creator or an admin_mod' do
    @comment.editable_by?(@commenter).should be_true
    @comment.editable_by?(@moderator).should be_true
    @comment.editable_by?(@user).should be_false
  end

  it 'should be edited given the valid parameters' do
    @comment.edit('Edited body.', @moderator)
    @comment.reload
    
    @comment.body.should == 'Edited body.'
    @comment.edited_at.should be_instance_of(Time)
    @comment.edited_by.should == @moderator.username
  end

  it 'should be reportable' do
    @comment.report @user, 'Whatever reason.', "comments_path/show/#{@comment.id}"
    Report.find_by_user_id_and_target_path(@user, "comments_path/show/#{@comment.id}").should_not be_nil
  end
end





