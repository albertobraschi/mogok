require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reward do
  include SupportVariables

  before(:each) do
    reload_support_variables
    
    @rewarder = make_user('joe-the-rewarder', @role_user)
    @rewarder.uploaded = 12345
    @rewarder.save

    @uploader  = make_user('joe-the-uploader', @role_user)
    @torrent = make_torrent(@uploader)
  end

  it 'should charge amount from the user who created it on creation' do
    make_reward(@torrent, @rewarder, 12345)
    @rewarder.reload

    @rewarder.uploaded.should == 0
  end

  it 'should increment torrent rewards counter on creation' do
    rewards_count = @torrent.rewards_count

    make_reward(@torrent, @rewarder, 12345)
    @torrent.reload

    @torrent.rewards_count.should == rewards_count + 1
  end

  it 'should add amount to torrent total reward on creation' do
    total_reward = @torrent.total_reward

    make_reward(@torrent, @rewarder, 12345)
    @torrent.reload

    @torrent.total_reward.should == total_reward + 12345
  end
end
