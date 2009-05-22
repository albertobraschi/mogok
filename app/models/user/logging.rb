
class User

  # logging concern

  private

    def add_log(key, args)
      Log.create I18n.t("model.user.#{key}", args)
    end

    def log_destruction(destroyer)
      add_log('log_destruction.log', :name => self.name, :by => destroyer.username)
    end
end