
module BgTasks

  class RatioWatch < AbstractBgTask

    protected

      def do_exec(params)
        params.values.each do |rule|
          rule.symbolize_keys!

          min_downloaded = rule[:min_downloaded].gigabytes
          max_downloaded = rule[:max_downloaded].gigabytes if rule[:max_downloaded]
          min_ratio = rule[:min_ratio]
          watch_until = rule[:period].days.from_now

          User.set_ratio_watch(min_downloaded, max_downloaded, min_ratio, watch_until)
          User.check_ratio_watch(min_downloaded, max_downloaded, min_ratio)
        end
      end
  end
end