require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WishComment do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @commenter    = make_user('joe-the-commenter', @role_user)
    @wisher       = make_user('joe-the-wisher', @role_user)
    @wish         = make_wish(@wisher)
    @wish_comment = make_wish_comment(@wish, @commenter)
  end

  it 'should be editable only by creator or an admin_mod' do
    @wish_comment.editable_by?(@commenter).should be_true
    @wish_comment.editable_by?(@mod).should be_true
    @wish_comment.editable_by?(@admin).should be_true
    @wish_comment.editable_by?(@user).should be_false
  end
  it 'should be edited given the valid parameters' do
    @wish_comment.edit('Edited body.', @mod)
    @wish_comment.reload

    @wish_comment.body.should == 'Edited body.'
    @wish_comment.edited_at.should be_instance_of(Time)
    @wish_comment.edited_by.should == @mod.username
  end

  it 'should be reportable' do
    @wish_comment.report @user, 'Whatever reason.', "comments/show/#{@wish_comment.id}"
    Report.find_by_user_id_and_target_path(@user, "comments/show/#{@wish_comment.id}").should_not be_nil
  end
end