require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LoginAttempt do
  include SupportVariables

  before(:each) do
    reload_support_variables
    
    @login_attempt = make_login_attempt('127.0.0.1')
  end

  it 'should be blocked for an IP if block until date is not expired' do
    @login_attempt.should_not be_blocked

    @login_attempt.blocked_until = 1.hour.from_now
    @login_attempt.should be_blocked
  end

  it 'should increment if max attempts not reached' do
    @login_attempt.attempts_count = 1
    @login_attempt.increment_or_block(5, 2)

    @login_attempt.attempts_count.should == 2
  end

  it 'should block if max attempts reached' do
    @login_attempt.attempts_count = 4
    @login_attempt.increment_or_block(5, 2)

    @login_attempt.should be_blocked
    @login_attempt.attempts_count.should == 0
  end
end
