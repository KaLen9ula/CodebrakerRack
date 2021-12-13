# frozen_string_literal: true

require 'simplecov'

require_relative '../autoloader'

SimpleCov.start do
  minimum_coverage 100
  add_filter 'spec'
  add_filter 'vendor'
end

RSpec.configure do |config|
  config.include SessionSaver
end
