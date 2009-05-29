require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  before(:each) do
    @reporter = fetch_user 'joe-the-reporter'
    @moderator = fetch_user 'joe-the-mod', fetch_role('mod')
    @torrent = fetch_torrent('Joe The Owners Torrent', 'joe-the-owner')
    @report = Report.create @torrent, @reporter, 'Whatever reason.', "torrents/show/#{@torrent.id}"
  end

  it 'should create a new instance given valid parameters' do
    @report.should be_valid
    @report.should_not be_new_record
  end

  it 'should have open reports after new report is created' do
    Report.has_open?.should be_true
  end

  it 'should generate a proper target label' do
    Report.make_target_label(@torrent).should == "torrent [#{@torrent.id}]"
  end

  it 'should be assigned to a user after assignment' do
    @report.assign_to @moderator
    @report.handler_id.should == @moderator.id
  end

  it 'should be not be assigned after unassignment' do
    @report.assign_to @moderator
    @report.unassign
    @report.handler_id.should be_nil
  end
end
