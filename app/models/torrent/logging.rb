
class Torrent

  # logging concern

  private

    def add_log(key, args)
      Log.create I18n.t("model.torrent.#{key}", args)
    end

    def log_upload
      add_log('log_upload.log', :name => self.name, :by => self.user.username)
    end

    def log_edition(editor, reason)
      add_log('log_edition.log', :name => self.name, :by => editor.username, :reason => reason)
    end

    def log_inactivation(inactivator, reason)
      add_log('log_inactivation.log', :name => self.name, :by => inactivator.username, :reason => reason)
    end

    def log_activation(activator)
      add_log('log_activation.log', :name => self.name, :by => activator.username)
    end

    def log_destruction(destroyer, reason)
      add_log('log_destruction.log', :name => self.name, :by => destroyer.username, :reason => reason)
    end
end