require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  include SupportVariables

  before(:each) do
    reload_support_variables
    
    @reporter = make_user('joe-the-reporter', @role_user)
    @uploader  = make_user('joe-the-uploader', @role_user)
    @torrent = make_torrent(@uploader)
    @report = make_report(@reporter)
  end

  it 'should build a new instance given valid parameters' do
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
    @report.assign_to @mod
    @report.handler_id.should == @mod.id
  end

  it 'should be not be assigned after unassignment' do
    @report.assign_to @mod
    @report.unassign
    @report.handler_id.should be_nil
  end
end
