
class Torrent

  # callbacks concern

  before_create :init_new_record
  before_save :trim_description
  after_create :create_fulltext
  after_update :update_fulltext

  private

    def init_new_record
      self.tags = Tag.parse_tags self.tags_str, self.category_id
      self.announce_key = CryptUtils.md5_token rand, 10
      self.info_hash_hex = CryptUtils.hexencode self.info_hash
    end

    def trim_description
      self.description = self.description[0, 10000] if self.description
    end

    def create_fulltext
      TorrentFulltext.create :torrent => self, :body => "#{self.name} #{self.description}"
    end

    def update_fulltext
      self.torrent_fulltext.update_attribute :body, "#{self.name} #{self.description}" if @update_fulltext
    end
end