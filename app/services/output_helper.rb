# frozen_string_literal: true

module Outputter
  def total_amount(codebraker_game, field)
    Codebraker::Game::DIFFICULTIES[codebraker_game.difficulty][field]
  end

  def level(codebraker_game)
    codebraker_game.difficulty.to_s.capitalize
  end
end
