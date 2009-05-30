require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  before(:each) do
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @user = fetch_user 'joe-the-user'
    @poster = fetch_user 'joe-the-poster'
    @forum = fetch_forum 'Some Forum'    
    @topic = Factory(:topic, :user => @poster, :forum => @forum)
    @post = Factory(:post, :user => @poster, :topic => @topic, :forum => @forum)
  end

  it 'should be editable only by creator or an admin_mod' do
    @post.editable_by?(@poster).should be_true
    @post.editable_by?(@moderator).should be_true
    @post.editable_by?(@user).should be_false
  end

  it 'should be edited given the valid parameters' do
    @post.edit('Edited body.', @moderator)
    @post.reload

    @post.body.should == 'Edited body.'
    @post.edited_at.should be_instance_of(Time)
    @post.edited_by.should == @moderator.username
  end

  it 'should be reportable' do
    @post.report @user, 'Whatever reason.', "posts_path/show/#{@post.id}"
    Report.find_by_user_id_and_target_path(@user, "posts_path/show/#{@post.id}").should_not be_nil
  end
end



