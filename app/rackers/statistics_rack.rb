# frozen_string_literal: true

class StatisticsRack < Racker
  def statistics
    rack_response('statistics')
  end
end
