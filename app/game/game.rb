class WebGame
  WIN_MATRIX = ['+'] * 4
  GAME_INSTANCE_VARIABLES = %i[@code @user @stage @difficulty @possible_hints].freeze

  attr_reader :codebraker_game

  def initialize(request)
    @request = request
    @codebraker_game = Codebraker::Game.new
    configure_game
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
    matrix = ['', '', '', ''].each_with_index.map { |char, index| matrix[index] || char }
    @request.session[:matrix] = matrix
    save_game
  end

  def clear_session
    @request.session[:matrix] = []
    @request.session[:hints] = []
  end

  def matrix
    @request.session[:matrix]
  end

  def current_game?
    @request.session.include?('codebraker_game') && validate_game_attributes?
  end

  def configure_game
    attributes = @request.session[:codebraker_game]
    attributes&.each { |key, value| @codebraker_game.instance_variable_set(key, value) }
  end

  def save_game
    attributes = {}
    @codebraker_game.instance_variables.each do |instance_variable|
      attributes[instance_variable] = @codebraker_game.instance_variable_get(instance_variable)
    end
    @request.session[:codebraker_game] = attributes
  end

  def hints
    @request.session[:hints]
  end

  def total_amount(field)
    Codebraker::Game::DIFFICULTIES[@codebraker_game.difficulty][field]
  end

  def level
    @codebraker_game.difficulty.to_s.upcase
  end

  def win?
    matrix == WIN_MATRIX
  end

  private

  def validate_game_attributes?
    game_attributes = @request.session[:codebraker_game]
    return unless game_attributes.is_a? Hash

    conditions = game_attributes.each_key.map do |instance_variable|
      GAME_INSTANCE_VARIABLES.include? instance_variable.to_sym
    end
    conditions.all?
  end
end
