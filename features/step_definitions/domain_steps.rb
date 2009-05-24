
Given /^I have a type with name (.*)$/ do |name|
  fetch_type name
end

Given /^I have a category with name (.*) and with type (.*)$/ do |name, type_name|
  fetch_category name, type_name
end

Given /^I have a format with name (.*) and with type (.*)$/ do |name, type_name|
  fetch_format name, type_name
end

Given /^I have a tag with name (.*) and with category (.*)$/ do |name, category_name|
  fetch_tag name, category_name
end
