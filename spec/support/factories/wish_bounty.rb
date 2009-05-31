
Factory.define :wish_bounty do |b|
  b.bounty_number { WishBounty.count + 1 }
end