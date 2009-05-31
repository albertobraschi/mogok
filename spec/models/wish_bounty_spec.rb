require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WishBounty do
  before(:each) do
    @bounter = fetch_user 'joe-the-bounter'
    @bounter.uploaded = 12345
    @bounter.save
    
    @wish = fetch_wish('Joe The Wishers Wish', 'joe-the-wisher')
  end

  it 'should charge bounty amount from the user who created it on creation' do
    Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)
    @bounter.reload

    @bounter.uploaded.should == 0
  end

  it 'should refund user if destroyed when not revoked or rewarded' do
    wb = Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)

    wb.destroy
    @bounter.reload

    @bounter.uploaded.should == 12345
  end

  it 'should refund user if revoked' do
    wb = Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)

    wb.revoke
    @bounter.reload

    @bounter.uploaded.should == 12345
  end

  it 'should subtract amount from wish total bounty if revoked' do
    wb = Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)
    @wish.reload
    
    total_bounty = @wish.total_bounty

    wb.revoke
    @wish.reload

    @wish.total_bounty.should == total_bounty - 12345
  end

  it 'should increment wish bounties counter on creation' do
    bounties_count = @wish.bounties_count

    Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)
    @wish.reload

    @wish.bounties_count.should == bounties_count + 1
  end

  it 'should add amount to wish total bounty on creation' do
    total_bounty = @wish.total_bounty

    Factory(:wish_bounty, :user => @bounter, :wish => @wish, :amount => 12345)
    @wish.reload

    @wish.total_bounty.should == total_bounty + 12345
  end
end
