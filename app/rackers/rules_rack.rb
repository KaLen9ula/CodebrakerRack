# frozen_string_literal: true

class RulesRack < Racker
  def rules
    rack_response('rules')
  end
end
