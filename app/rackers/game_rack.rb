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
    return redirect('/') unless @game_manager.current_game? || @game_manager.win?

    @game_manager.codebraker_game.save_game(@game_manager.codebraker_game)
    response = rack_response('win')
    @request.session.clear
    response
  end

  def lose
    return redirect('/') unless @game_manager.current_game?

    response = rack_response('lose')
    @request.session.clear
    response
  end

  def game
    return redirect('/') unless @game_manager.current_game?

    rack_response('game')
  end

  def hint
    return redirect('/') unless @game_manager.current_game?

    @game_manager.give_hint if @game_manager.codebraker_game.check_for_hints?
    redirect('game')
  end

  def guess
    return redirect('/') unless @game_manager.current_game?
    return redirect('game') if @request.params['number'].nil?

    @game_manager.configure_game_session
    return win_redirection if win_codition?
    return redirect('lose') if @game_manager.codebraker_game.lose?

    redirect('game')
  end

  def index
    return redirect('game') if @game_manager.current_game?
    return rack_response('menu') if @request.params.empty?

    @game_manager.configure_codebraker_game
    @game_manager.clear_session
    redirect('game')
  end

  private

  def win_codition?
    @game_manager.codebraker_game.win?(@request.params['number'])
  end

  def win_redirection
    @game_manager.save_game
    redirect('win')
  end
end
