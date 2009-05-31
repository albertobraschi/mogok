require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Forum do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @poster = make_user('joe-the-poster', @role_user)
    @forum = make_forum
  end

  it 'should be editable only by an admin' do
    @forum.editable_by?(@admin).should be_true
    @forum.editable_by?(@mod).should be_false
    @forum.editable_by?(@user).should be_false
  end

  it 'should be edited given the valid parameters' do
    @forum.update_attributes(:name => 'Edited Name', :description => 'Edited description.', :position => '666')
    @forum.reload
    
    @forum.name.should == 'Edited Name'
    @forum.description.should == 'Edited description.'
    @forum.position.should == 666
  end

  it 'should add a topic to itself given the valid parameters' do
    topics_count = @forum.topics_count

    @forum.add_topic('Topic Title', 'Topic body.', @poster)
    @forum.reload

    t = Topic.find_by_forum_id_and_title_and_user_id(@forum, 'Topic Title', @poster)
    t.should_not be_nil
    t.topic_post.body.should == 'Topic body.'
    t.topic_post.forum.should == @forum
    t.topic_post.post_number.should == 1
    t.topic_post.is_topic_post.should be_true
    t.topic_post.user.should == @poster
    
    @forum.topics_count.should == topics_count + 1
    @forum.search({}, :per_page => 10).should include(t)
  end
end

