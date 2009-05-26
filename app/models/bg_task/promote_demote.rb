
class BgTask

  # promote_demote concern

  def self.promote_demote(params)
    params.values.each do |rule|
      rule.symbolize_keys!
      User.promote_demote_by_data_transfer rule[:lower],
                                           rule[:higher],
                                           rule[:min_uploaded].gigabytes,
                                           rule[:min_ratio]
    end
  end
end
