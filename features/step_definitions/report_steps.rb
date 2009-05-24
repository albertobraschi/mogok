
# THEN

Then /^a moderation report for wish (.*) should be created$/ do |wish_name|
  w = Wish.find_by_name(wish_name)
  l = Report.make_target_label(w)
  Report.find_by_target_label(l).should_not == nil
end
