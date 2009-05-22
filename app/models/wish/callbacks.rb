
class Wish

  # callbacks concern

  after_create :create_fulltext, :log_creation
  after_update :update_fulltext

  private

    def create_fulltext
      WishFulltext.create :wish => self, :body => "#{self.name} #{self.description}"
    end

    def update_fulltext
      self.wish_fulltext.update_attribute :body, "#{self.name} #{self.description}" if @update_fulltext
    end
end