# frozen_string_literal: true

require_relative '../app_config'
require_relative '../services/output_helper'

class Racker
  include Outputter
  include WebActions
  include AppConfig

  def initialize(request)
    @request = request
  end
end
