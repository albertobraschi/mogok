
Factory.define :reward do |r|
  r.reward_number { Reward.count + 1 }
end