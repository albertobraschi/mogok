require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WishBounty do
  include SupportVariables

  before(:each) do
    reload_support_variables
    
    @bounter = make_user('joe-the-bounter', @role_user)
    @bounter.uploaded = 12345
    @bounter.save
    
    @wisher = make_user('joe-the-wisher', @role_user)
    @wish   = make_wish(@wisher)
  end

  it 'should charge bounty amount from the bounter on creation' do
    make_wish_bounty(@wish, @bounter, 12345)
    @bounter.reload

    @bounter.uploaded.should == 0
  end

  it 'should refund user if destroyed when not revoked or rewarded' do
    wb = make_wish_bounty(@wish, @bounter, 12345)

    wb.destroy
    @bounter.reload

    @bounter.uploaded.should == 12345
  end

  it 'should refund user if revoked' do
    wb = make_wish_bounty(@wish, @bounter, 12345)

    wb.revoke
    @bounter.reload

    @bounter.uploaded.should == 12345
  end

  it 'should subtract amount from wish total bounty if revoked' do
    wb = make_wish_bounty(@wish, @bounter, 12345)
    @wish.reload
    
    total_bounty = @wish.total_bounty

    wb.revoke
    @wish.reload

    @wish.total_bounty.should == total_bounty - 12345
  end

  it 'should increment wish bounties counter on creation' do
    bounties_count = @wish.bounties_count

    make_wish_bounty(@wish, @bounter, 12345)
    @wish.reload

    @wish.bounties_count.should == bounties_count + 1
  end

  it 'should add amount to wish total bounty on creation' do
    total_bounty = @wish.total_bounty

    make_wish_bounty(@wish, @bounter, 12345)
    @wish.reload

    @wish.total_bounty.should == total_bounty + 12345
  end
end
