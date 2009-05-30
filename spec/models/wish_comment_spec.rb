require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WishComment do
  before(:each) do
    @commenter = fetch_user 'joe-the-commenter'
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @user = fetch_user 'joe-the-user'
    @wish = fetch_wish('Joe The Wishers Wish', 'joe-the-wisher')
    @wish_comment = Factory(:wish_comment, :user => @commenter, :wish => @wish)
  end

  it 'should be editable only by creator or an admin_mod' do
    @wish_comment.editable_by?(@commenter).should be_true
    @wish_comment.editable_by?(@moderator).should be_true    
    @wish_comment.editable_by?(@user).should be_false
  end
  it 'should be edited given the valid parameters' do
    @wish_comment.edit('Edited body.', @moderator)
    @wish_comment.reload

    @wish_comment.body.should == 'Edited body.'
    @wish_comment.edited_at.should be_instance_of(Time)
    @wish_comment.edited_by.should == @moderator.username
  end

  it 'should be reportable' do
    @wish_comment.report @user, 'Whatever reason.', "comments/show/#{@wish_comment.id}"
    Report.find_by_user_id_and_target_path(@user, "comments/show/#{@wish_comment.id}").should_not be_nil
  end
end