# frozen_string_literal: true

class Racker
  include Outputter
  include WebActions
  include AppConfig

  def initialize(request)
    @request = request
  end
end
