# frozen_string_literal: true

class GameRack < Racker
  def initialize(request)
    super
    @game_manager = WebGame.new(@request)
  end

  def win
    return redirect(ROOT_PATH) unless @game_manager.game_exists? || win_codition?

    @game_manager.codebraker_game.save_game(@game_manager.codebraker_game)
    @response = rack_response(WIN_PATH)
    @request.session.clear
    @response
  end

  def lose
    return redirect(ROOT_PATH) unless @game_manager.game_exists?

    @response = rack_response(LOSE_PATH)
    @request.session.clear
    @response
  end

  def game
    current_game_to_index_redirect

    @response || rack_response(GAME_PATH)
  end

  def hint
    current_game_to_index_redirect

    @game_manager.give_hint if @response.nil? && @game_manager.codebraker_game.check_for_hints?

    @response || redirect(GAME_PATH)
  end

  def guess
    current_game_to_index_redirect || check_number_params_redirect

    unless @response
      @game_manager.configure_game_session
      win_redirection || lose_redirection
    end
    @response || redirect(GAME_PATH)
  end

  def index
    @response = redirect(GAME_PATH) if @game_manager.game_exists?
    @response = rack_response('menu') if !@response && @request.params.empty?

    unless @response
      @game_manager.configure_codebraker_game
      @game_manager.clear_game_data_session
    end
    @response || redirect(GAME_PATH)
  end

  private

  def win_codition?
    @game_manager.codebraker_game.win?(@request.params['number'])
  end

  def win_redirection
    return unless win_codition?

    @game_manager.save_game
    @response = redirect(WIN_PATH)
  end

  def lose_redirection
    @response = redirect(LOSE_PATH) if @game_manager.codebraker_game.lose?
  end

  def current_game_to_index_redirect
    @response = redirect(ROOT_PATH) unless @game_manager.game_exists?
  end

  def current_game_to_game_redirect
    @response = redirect(GAME_PATH) unless @game_manager.game_exists?
  end

  def check_number_params_redirect
    @response = redirect(GAME_PATH) if @request.params['number'].nil?
  end

  def check_params_redirect
    @response = rack_response('menu') if @request.params.empty?
  end
end
