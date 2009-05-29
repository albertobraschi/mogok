require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  before(:each) do
    u = fetch_user('joe-the-reporter')
    t = fetch_torrent('Joe The Owners Torrent', 'joe-the-owner')
    @report = Report.create(t, u, 'Whatever reason.', "torrents/show/#{t.id}")
  end

  it 'should create a new instance given valid parameters' do
    @report.should be_valid
    @report.should_not be_new_record
  end

  it 'should have an open report after new report is created' do
    Report.has_open?.should be_true
  end

  it 'should generate a proper target label' do
    t = fetch_torrent('Joe The Owners Torrent', 'joe-the-owner')
    Report.make_target_label(t).should == "torrent [#{t.id}]"
  end

  it 'should be assigned to a user after assignment' do
    u = fetch_user('joe-the-mod')
    @report.assign_to u
    @report.handler_id.should == u.id
  end

  it 'should be not be assigned after unassignment' do
    u = fetch_user('joe-the-mod')
    @report.assign_to u
    @report.unassign
    @report.handler_id.should be_nil
  end
end
