
class Log < ActiveRecord::Base

  def self.search(params, searcher, args)
    paginate :conditions => search_conditions(params, searcher),
             :order => order_by(params[:order_by], params[:desc]),
             :page => params[:page],
             :per_page => args[:per_page]
  end

  def self.create(body, admin = false)
    super :body => body, :admin => admin
  end

  def self.delete_olds(threshold)
    delete_all ['created_at < ?', threshold]
  end

  private

    def self.search_conditions(params, searcher)
      s, h = '', {}
      if searcher.admin?
        if params[:admin] == '1'
          s << 'admin = TRUE '
          previous = true
        end
      else
        s << 'admin = FALSE '
        previous = true
      end
      unless params[:keywords].blank?
        s << 'AND ' if previous
        s << 'body LIKE :keywords'
        h[:keywords] = "%#{params[:keywords]}%"
      end
      [s, h]
    end
end
