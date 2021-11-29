# frozen_string_literal: true

class GameRack < Racker
  ROUTES = {
    '/' => :index,
    '/submit_answer' => :guess,
    '/game' => :game,
    '/hint' => :hint,
    '/win' => :win,
    '/lose' => :lose
  }.freeze

  def initialize(request)
    super
    @game_manager = WebGame.new(@request)
  end

  def win
    response = redirect(I18n.t('pages.index')) unless @game_manager.current_game? || win_codition?

    if response.nil?
      @game_manager.codebraker_game.save_game(@game_manager.codebraker_game)
      response = rack_response(I18n.t('pages.win'))
      @request.session.clear
    end
    response
  end

  def lose
    current_game_to_index_redirect

    if @response.nil?
      @response = rack_response(I18n.t('pages.lose'))
      @request.session.clear
    end
    @response
  end

  def game
    current_game_to_index_redirect

    @response || rack_response(I18n.t('pages.game'))
  end

  def hint
    current_game_to_index_redirect

    @game_manager.give_hint if @response.nil? && @game_manager.codebraker_game.check_for_hints?

    @response || redirect(I18n.t('pages.game'))
  end

  def guess
    current_game_to_index_redirect || check_number_params_redirect

    if @response.nil?
      @game_manager.configure_game_session
      win_redirection || lose_redirection
    end

    @response || redirect(I18n.t('pages.game'))
  end

  def index
    response = redirect(I18n.t('pages.game')) if @game_manager.current_game?
    response = rack_response(I18n.t('pages.menu')) if !response && @request.params.empty?

    if response.nil?
      @game_manager.configure_codebraker_game
      @game_manager.clear_session
    end
    response || redirect(I18n.t('pages.game'))
  end

  private

  def win_codition?
    @game_manager.codebraker_game.win?(@request.params['number'])
  end

  def win_redirection
    return unless win_codition?

    @game_manager.save_game
    @response = redirect(I18n.t('pages.win'))
  end

  def lose_redirection
    @response = redirect(I18n.t('pages.lose')) if @game_manager.codebraker_game.lose?
  end

  def current_game_to_index_redirect
    @response = redirect(I18n.t('pages.index')) unless @game_manager.current_game?
  end

  def current_game_to_game_redirect
    @response = redirect(I18n.t('pages.game')) unless @game_manager.current_game?
  end

  def check_number_params_redirect
    @response = redirect(I18n.t('pages.game')) if @request.params['number'].nil?
  end

  def check_params_redirect
    @response = rack_response(I18n.t('pages.menu')) if @request.params.empty?
  end
end
