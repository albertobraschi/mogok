
class Bookmark < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user

  def self.toggle_bookmarked(t, u)
    b = u.bookmarks.find_by_torrent_id t
    if b
      b.destroy
      t.bookmarked = false
    else
      b = Bookmark.create :torrent => t, :user => u
      t.bookmarked = true
    end
  end
end
