# frozen_string_literal: true

RSpec.describe App do
  include Rack::Test::Methods

  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebraker::Game.new }
  let(:player_name) { 'test' }
  let(:level) { 'easy' }
  let(:levels) { Codebraker::Game::DIFFICULTIES }

  before do
    stub_const('Codebraker::FileStore::FILE_NAME', 'gamers.yml')
    stub_const('Codebraker::FileStore::FILE_DIRECTORY', 'spec/fixtures')
  end

  describe '#index' do
    context 'when form is empty' do
      before do
        get AppConfig::ROOT_PATH
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end

      it 'not save session' do
        expect(last_request.session).to be_empty
      end

      it 'correct displays levels' do
        levels.each_key do |level|
          expect(last_response.body).to include(level.to_s.capitalize)
        end
      end
    end

    context 'when form is filled' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq AppConfig::GAME_PATH
      end

      it 'save hints in session' do
        expect(last_request.session[:hints]).to eq []
      end

      it 'save matrix in session' do
        expect(last_request.session[:matrix]).to eq []
      end
    end

    context 'when session is not empty' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        get AppConfig::ROOT_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq AppConfig::GAME_PATH
      end
    end
  end

  describe '#game' do
    context 'when session is empty' do
      before do
        clear_cookies
        get AppConfig::GAME_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq AppConfig::ROOT_PATH
      end
    end

    context 'when correct start' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        get AppConfig::GAME_PATH
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include(levels[level.to_sym][:attempts].to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include(levels[level.to_sym][:hints].to_s)
      end
    end
  end

  describe '#submit_answer' do
    context 'when correct submit' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        post AppConfig::GUESS_PATH, number: '1111'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq AppConfig::GAME_PATH
      end

      it 'correct save matrix' do
        expect(last_request.session[:matrix].length).to eq 1
      end
    end

    context 'when move to game page' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        post AppConfig::GUESS_PATH, number: '1111'
        get AppConfig::GAME_PATH
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include((levels[level.to_sym][:attempts] - 1).to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include(levels[level.to_sym][:hints].to_s)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        post AppConfig::GUESS_PATH, number: '1111'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq AppConfig::ROOT_PATH
      end
    end
  end

  describe '#hint' do
    context 'when game is start' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
      end

      it 'expect game to be empty' do
        expect(last_request.session[:hints]).to be_empty
      end
    end

    context 'when take hint' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        post AppConfig::HINT_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq AppConfig::GAME_PATH
      end

      it 'increased by one' do
        expect(last_request.session[:hints].length).to eq 1
      end
    end

    context 'when move to game page' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        post AppConfig::HINT_PATH
        get AppConfig::GAME_PATH
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include(levels[level.to_sym][:attempts].to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include((levels[level.to_sym][:hints] - 1).to_s)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get AppConfig::HINT_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq AppConfig::ROOT_PATH
      end
    end
  end

  describe '#win' do
    before do
      post AppConfig::ROOT_PATH, player_name: player_name, level: level
    end

    context 'when user guessed' do
      before do
        post AppConfig::GUESS_PATH, number: load_session(last_request.session[:id]).code
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to win page' do
        expect(last_response.location).to eq AppConfig::WIN_PATH
      end
    end

    context 'when redirect to win page' do
      before do
        post AppConfig::GUESS_PATH, number: load_session(last_request.session[:id]).code
        get AppConfig::WIN_PATH
      end

      it 'clear session' do
        expect(last_request.session).to be_empty
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{levels[level.to_sym][:attempts] - 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{levels[level.to_sym][:hints]}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get AppConfig::WIN_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq AppConfig::ROOT_PATH
      end
    end
  end

  describe '#lose' do
    before do
      stub_const('Codebraker::Game::DIFFICULTIES', { level.to_sym => { attempts: 1, hints: 1 } })
      post AppConfig::ROOT_PATH, player_name: player_name, level: level
      post AppConfig::GUESS_PATH, number: '1112'
    end

    it 'return 302' do
      expect(last_response.status).to eq 302
    end

    it 'redirect to lose page' do
      expect(last_response.location).to eq AppConfig::LOSE_PATH
    end

    context 'when redirect to lose page' do
      before do
        get AppConfig::LOSE_PATH
      end

      it 'clear session' do
        expect(last_request.session).to be_empty
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{levels[level.to_sym][:attempts] - 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{levels[level.to_sym][:hints]}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get AppConfig::LOSE_PATH
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq AppConfig::ROOT_PATH
      end
    end
  end

  describe '#statistics' do
    context 'when move to statistics page' do
      before do
        get AppConfig::STATISTICS_PATH
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end
    end

    context 'when user guessed' do
      before do
        post AppConfig::ROOT_PATH, player_name: player_name, level: level
        post AppConfig::GUESS_PATH, number: load_session(last_request.session[:id]).code
        get AppConfig::WIN_PATH
        get AppConfig::STATISTICS_PATH
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{game.user.attempts + 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{game.user.hints}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end
    end
  end

  describe '#rules' do
    before do
      get AppConfig::RULES_PATH
    end

    it 'return 200' do
      expect(last_response.status).to eq 200
    end
  end

  describe '#unreacheble_path' do
    before do
      get '/unreacheble_path'
    end

    it 'redirect to menu page' do
      expect(last_response.location).to eq AppConfig::ROOT_PATH
    end
  end
end
