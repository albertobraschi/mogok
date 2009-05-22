
class Wish

  # logging concern

  private

    def add_log(key, args)
      Log.create I18n.t("model.wish.#{key}", args)
    end

    def log_creation
      add_log('log_creation.log', :name => self.name, :by => self.user.username)
    end

    def log_approval
      add_log('log_approval.log', :name => self.name, :by => self.filler.username)
    end

    def log_destruction(destroyer, reason)
      add_log('log_destruction.log', :name => self.name, :by => destroyer.username, :reason => reason)
    end
end