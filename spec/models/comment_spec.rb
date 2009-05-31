require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @uploader  = make_user('joe-the-uploader', @role_user)
    @commenter = make_user('joe-the-commenter', @role_user)
    @torrent = make_torrent(@uploader)
    @comment = make_comment(@torrent, @commenter)
  end

  it 'should be editable only by creator or an admin_mod' do
    @comment.editable_by?(@commenter).should be_true
    @comment.editable_by?(@mod).should be_true
    @comment.editable_by?(@admin).should be_true
    @comment.editable_by?(@user).should be_false
  end

  it 'should be edited given the valid parameters' do
    @comment.edit('Edited body.', @mod)
    @comment.reload
    
    @comment.body.should == 'Edited body.'
    @comment.edited_at.should be_instance_of(Time)
    @comment.edited_by.should == @mod.username
  end

  it 'should be reportable' do
    @comment.report @user, 'Whatever reason.', "comments_path/show/#{@comment.id}"
    Report.find_by_user_id_and_target_path(@user, "comments_path/show/#{@comment.id}").should_not be_nil
  end
end





