
class User

  # logging concern

  private

    def add_log(key, args)
      Log.create I18n.t("model.user.#{key}", args)
    end

    def log_destruction(destroyer)
      add_log('log_destruction.log', :username => self.username, :by => destroyer.username)
    end
end