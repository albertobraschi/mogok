require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Topic do
  before(:each) do
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @user = fetch_user 'joe-the-user'
    @poster = fetch_user 'joe-the-poster'
    @forum = fetch_forum 'Some Forum'
    @topic = Factory(:topic, :user => @poster, :forum => @forum)
  end

  it 'should be edited given the valid parameters' do
    @topic.edit('Edited Title', 'Edited topic body.', @moderator)

    @topic.title.should == 'Edited Title'
    @topic.topic_post.body.should == 'Edited topic body.'
    @topic.topic_post.edited_at.should be_instance_of(Time)
    @topic.topic_post.edited_by.should == @moderator.username
  end

  it 'should add a post to itself given the valid parameters' do
    replies_count = @topic.replies_count

    @topic.add_post('Post body.', @poster)
    
    Post.find_by_topic_id_and_body_and_user_id(@topic, 'Post body.', @poster).should_not be_nil
    @topic.replies_count.should == replies_count + 1
    @topic.last_post_by.should == @poster.username
  end

  it 'should decrement forum topics counter after destruction' do
    @forum.topics_count = 1
    @forum.save

    @topic.destroy
    @forum.topics_count.should == 0
  end

  it 'should be editable only by creator or an admin_mod' do
    @topic.editable_by?(@poster).should be_true
    @topic.editable_by?(@moderator).should be_true
    @topic.editable_by?(@user).should be_false
  end

  it 'should be reportable' do
    @topic.report @user, 'Whatever reason.', "topics_path/show/#{@topic.id}"
    Report.find_by_user_id_and_target_path(@user, "topics_path/show/#{@topic.id}").should_not be_nil
  end
end

