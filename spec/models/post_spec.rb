require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @poster = make_user('joe-the-poster', @role_user)
    @forum  = make_forum
    @topic  = make_topic(@forum, @poster)
    @post   = make_post(@forum, @topic, @poster)
  end

  it 'should be editable only by creator or an admin_mod' do
    @post.editable_by?(@poster).should be_true
    @post.editable_by?(@mod).should be_true
    @post.editable_by?(@admin).should be_true
    @post.editable_by?(@user).should be_false
  end

  it 'should be edited given the valid parameters' do
    @post.edit('Edited body.', @mod)
    @post.reload

    @post.body.should == 'Edited body.'
    @post.edited_at.should be_instance_of(Time)
    @post.edited_by.should == @mod.username
  end

  it 'should be reportable' do
    @post.report @user, 'Whatever reason.', "posts_path/show/#{@post.id}"
    Report.find_by_user_id_and_target_path(@user, "posts_path/show/#{@post.id}").should_not be_nil
  end
end



