# frozen_string_literal: true

require_relative 'app_config'

class App
  include WebActions
  include AppConfig
  ROUTES = { ROOT_PATH => { class: GameRack, method: :index },
             GUESS_PATH => { class: GameRack, method: :guess },
             GAME_PATH => { class: GameRack, method: :game },
             HINT_PATH => { class: GameRack, method: :hint },
             WIN_PATH => { class: GameRack, method: :win },
             LOSE_PATH => { class: GameRack, method: :lose },
             RULES_PATH => { class: RulesRack, method: :rules },
             STATISTICS_PATH => { class: StatisticsRack, method: :statistics } }.freeze

  def self.call(env)
    new(env).response.finish
  end

  def response
    path = @request.path
    return ROUTES[path][:class].new(@request).public_send(ROUTES[path][:method]) if ROUTES.key?(path)

    redirect(ROOT_PATH)
  end

  private

  def initialize(env)
    @request = Rack::Request.new(env)
  end
end
