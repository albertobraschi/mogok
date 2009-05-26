
class BgTask

  # ratio_watch concern

  def self.ratio_watch(params)
    params.values.each do |rule|
      rule.symbolize_keys!

      min_downloaded = rule[:min_downloaded].gigabytes
      max_downloaded = rule[:max_downloaded].gigabytes if rule[:max_downloaded]
      min_ratio      = rule[:min_ratio]
      watch_until    = rule[:period].days.from_now

      User.start_ratio_watch(min_downloaded, max_downloaded, min_ratio, watch_until)
      User.finish_ratio_watch(min_downloaded, max_downloaded, min_ratio)
    end
  end
end









