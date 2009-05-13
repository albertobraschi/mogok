
module PeersHelper

  def peer_completion(n)
    number_with_precision n, t('number.peer_completion.format')
  end
end
