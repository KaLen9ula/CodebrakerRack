# frozen_string_literal: true

class Racker
  include WebActions
  ROUTES = {}.freeze

  def initialize(request)
    @request = request
  end

  def response
    path = @request.path
    public_send(self.class::ROUTES[path])
  end
end
