
class Log < ActiveRecord::Base

  def self.search(params, searcher, *args)
    options = args.pop
    params[:order_by], params[:desc] = 'created_at', '1' if params[:order_by].blank?

    paginate :conditions => search_conditions(params, searcher),
             :order => order_by(params[:order_by], params[:desc]),
             :page => current_page(params[:page]),
             :per_page => options[:per_page]
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
