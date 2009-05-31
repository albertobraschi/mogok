require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reward do
  before(:each) do
    @rewarder = fetch_user 'joe-the-rewarder'
    @rewarder.uploaded = 12345
    @rewarder.save

    @torrent = fetch_torrent('Joe The Uploaders Torrent', 'joe-the-uploader')
  end

  it 'should charge amount from the user who created it on creation' do
    Factory(:reward, :user => @rewarder, :torrent => @torrent, :amount => 12345)
    @rewarder.reload

    @rewarder.uploaded.should == 0
  end

  it 'should increment torrent rewards counter on creation' do
    rewards_count = @torrent.rewards_count

    Factory(:reward, :user => @rewarder, :torrent => @torrent, :amount => 12345)
    @torrent.reload

    @torrent.rewards_count.should == rewards_count + 1
  end

  it 'should add amount to torrent total reward on creation' do
    total_reward = @torrent.total_reward

    Factory(:reward, :user => @rewarder, :torrent => @torrent, :amount => 12345)
    @torrent.reload

    @torrent.total_reward.should == total_reward + 12345
  end
end
