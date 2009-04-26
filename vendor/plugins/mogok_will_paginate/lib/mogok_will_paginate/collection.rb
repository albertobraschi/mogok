
module WillPaginate
  
  class Collection < Array
    attr_accessor :html_anchor, :desc_by_default, :order_by
  end
end