# frozen_string_literal: true

class StatisticsRack < Racker
  ROUTES = {
    '/statistics' => :statistics
  }.freeze

  def statistics
    rack_response('statistics')
  end
end
