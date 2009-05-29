require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  before(:each) do
    @category_music = fetch_category 'music', 'audio'
    @category_audio_book = fetch_category 'audio_book', 'audio'
    @tag_pop = fetch_tag 'pop', 'music'
    @tag_rock = fetch_tag 'rock', 'music'
    @tag_fiction = fetch_tag 'fiction', 'audio_book'
  end

  it 'should parse a string containing tags separated by commas' do
    a = Tag.parse_tags('pop, rock, fiction')
    a.should include(@tag_pop)
    a.should include(@tag_rock)
    a.should include(@tag_fiction)
  end

  it 'should parse a string containing tags separated by commas scoped by category' do
    a = Tag.parse_tags('pop, rock, fiction', @category_music)
    a.should include(@tag_pop)
    a.should include(@tag_rock)
    a.should_not include(@tag_fiction)
  end
end