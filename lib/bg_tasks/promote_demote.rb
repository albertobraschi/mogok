
module BgTasks

  class PromoteDemote < AbstractBgTask

    protected

      def do_exec(params)
        params.values.each do |rule|
          rule.symbolize_keys!          
          User.promote_demote_by_data_transfer rule[:lower],
                                               rule[:higher],
                                               rule[:min_uploaded].gigabytes,
                                               rule[:min_ratio]
        end
      end
  end
end
