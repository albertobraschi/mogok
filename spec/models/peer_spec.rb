require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Peer do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @announcer = make_user('joe-the-uploader', @role_user)
    @announcer = make_user('joe-the-announcer', @role_user)
    @torrent   = make_torrent(@uploader)
    @client    = fetch_client('UT')
  end

  it 'should create a new record given the valid parameters' do
    h = {}
    h[:torrent]           = @torrent
    h[:user]              = @announcer
    h[:ip]                = '127.0.0.1'
    h[:port]              = 33333
    h[:uploaded]          = 0
    h[:downloaded]        = 0
    h[:left]              = @torrent.size
    h[:seeder]            = false
    h[:peer_id]           = 'PEER_ID'
    h[:current_action_at] = Time.now
    h[:client]            = @client

    p = Peer.create(h)
    p.reload
    p.compact_ip.should_not be_nil
    p.peer_conn.should_not be_nil
  end

  # callbacks concern

    it 'should increment torrent seeders counter on creation' do
      seeders_count = @torrent.seeders_count
      p = make_peer @torrent, @announcer, '127.0.0.1', 33333, true
      @torrent.reload

      @torrent.seeders_count.should == seeders_count + 1
    end

    it 'should increment torrent leechers counter on creation' do
      leechers_count = @torrent.leechers_count
      p = make_peer @torrent, @announcer, '127.0.0.1', 33333, false
      @torrent.reload

      @torrent.leechers_count.should == leechers_count + 1
    end

    it 'should decrement torrent seeders counter on destruction' do
      p = make_peer @torrent, @announcer, '127.0.0.1', 33333, true
      @torrent.reload
      seeders_count = @torrent.seeders_count

      p.destroy
      @torrent.reload

      @torrent.seeders_count.should == seeders_count - 1
    end

    it 'should decrement torrent leechers counter on destruction' do
      p = make_peer @torrent, @announcer, '127.0.0.1', 33333, false
      @torrent.reload
      leechers_count = @torrent.leechers_count

      p.destroy
      @torrent.reload

      @torrent.leechers_count.should == leechers_count - 1
    end
end
