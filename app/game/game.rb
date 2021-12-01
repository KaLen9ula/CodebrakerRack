# frozen_string_literal: true

require_relative '../services/session_saver'

class WebGame
  include SessionSaver

  attr_reader :codebraker_game

  def initialize(request)
    @request = request
    @codebraker_game = load_session(@request.session[:id]) || Codebraker::Game.new
  end

  def give_hint
    @request.session[:hints] << @codebraker_game.use_hint
    save_game
  end

  def configure_codebraker_game
    @codebraker_game.difficulty = @request.params['level'].downcase.to_sym
    @codebraker_game.user.name = @request.params['player_name']
    @codebraker_game.start
    save_game
  end

  def configure_game_session
    matrix = @codebraker_game.generate_signs(@request.params['number']).chars
    @request.session[:matrix] = matrix
    save_game
  end

  def matrix
    @request.session[:matrix]
  end

  def current_game?
    @request.session.include?('id')
  end

  def save_game
    session_id = save_session(@codebraker_game)
    @request.session[:id] = session_id
  end

  def clear_data_session
    @request.session[:matrix] = []
    @request.session[:hints] = []
  end

  def hints
    @request.session[:hints]
  end

  def total_amount(field)
    Codebraker::Game::DIFFICULTIES[@codebraker_game.difficulty][field]
  end

  def level
    @codebraker_game.difficulty.to_s.capitalize
  end
end
