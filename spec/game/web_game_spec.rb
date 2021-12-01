# frozen_string_literal: true

RSpec.describe WebGame do
  let(:request) { instance_double('Request') }
  let(:game_manager) { described_class.new(request) }
  let(:player_name) { 'test' }
  let(:level) { 'easy' }
  let(:guess) { '1111' }

  before do
    allow(request).to receive(:session).and_return({})
    allow(request).to receive(:params).and_return({ 'player_name' => player_name, 'level' => level })
  end

  it 'saves request' do
    expect(game_manager.instance_variable_get(:@request)).to eq request
  end

  it 'correct create instance Codebreaker::Game' do
    expect(game_manager.codebraker_game).to be_instance_of Codebraker::Game
  end

  describe '#give_hint' do
    before do
      game_manager.configure_codebraker_game
      game_manager.clear_data_session
    end

    it 'saves hint in session' do
      expect { game_manager.give_hint }.to change { request.session[:hints].size }.by(1)
    end

    context 'when hint is given' do
      before do
        game_manager.give_hint
      end

      it 'expects hint to be given' do
        expect(request.session[:hints].first.to_i).to be > 0
      end
    end
  end

  describe '#configure_game_session' do
    before do
      allow(request).to receive(:params).and_return({ 'number' => guess })
      game_manager.codebraker_game.instance_variable_set(:@stage, Codebraker::Settings::IN_GAME)
      game_manager.configure_game_session
    end

    it 'saves matrix to session' do
      expect(request.session.keys).to include :matrix
    end

    it 'saves matrix an array' do
      expect(request.session[:matrix]).to be_instance_of Array
    end

    it 'saves matrix an array of length four' do
      expect(request.session[:matrix].size).to eq 0
    end
  end

  describe '#current_game??' do
    it 'returns false' do
      expect(game_manager).not_to be_current_game
    end

    context 'when game id is included in session' do
      before do
        allow(request).to receive(:session).and_return({})
      end

      it do
        expect(game_manager).not_to be_current_game
      end
    end

    context 'when game id is not included in session' do
      before do
        allow(request).to receive(:session).and_return({ 'id' => '1' })
      end

      it do
        expect(game_manager).to be_current_game
      end
    end
  end

  describe '#clear_session' do
    before do
      game_manager.clear_data_session
    end

    it 'saves empty matrix array to session' do
      expect(request.session[:matrix]).to eq []
    end

    it 'saves empty array of hints to session' do
      expect(request.session[:hints]).to eq []
    end
  end

  describe '#matrix' do
    let(:matrix) { ['', '', '', ''] }

    before do
      allow(request).to receive(:session).and_return({ matrix: matrix })
    end

    it 'returns matrix' do
      expect(game_manager.matrix).to eq matrix
    end
  end

  describe '#hints' do
    let(:hints) { ['', '', '', ''] }

    before do
      allow(request).to receive(:session).and_return({ hints: hints })
    end

    it 'returns hints' do
      expect(game_manager.hints).to eq hints
    end
  end
end
