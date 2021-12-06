# frozen_string_literal: true

RSpec.describe GameRack do
  let(:request) { instance_double('Request') }
  let(:game_rack) { described_class.new(request) }
  let(:game_manager) { WebGame.new(request) }
  let(:guess) { '1111' }

  before do
    allow(request).to receive(:session).and_return({})
    allow(File).to receive(:read).and_return('')
    game_rack.instance_variable_set(:@game_manager, game_manager)
  end

  it 'saves request' do
    expect(game_rack.instance_variable_get(:@request)).to eq request
  end

  it 'has session clear' do
    expect(game_rack.instance_variable_get(:@request).session).to be_empty
  end

  describe '#lose' do
    context 'when codebreaker game is not in session' do
      it { expect(game_rack.lose).to be_instance_of Rack::Response }

      it { expect(game_rack.lose.location).to eq '/' }

      it { expect(game_rack.lose.status).to eq 302 }
    end

    context 'when codebraker game in session' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.lose).to be_instance_of Rack::Response }

      it { expect(game_rack.lose.status).to eq 200 }
    end
  end

  describe '#win' do
    before do
      allow(game_manager).to receive_message_chain(:codebraker_game, :save_game)
    end

    context 'when codebraker game is not in session' do
      before do
        allow(game_manager).to receive_message_chain(:codebraker_game, :win?).and_return(false)
        allow(request).to receive(:params).and_return({ 'number' => guess })
      end

      it { expect(game_rack.win).to be_instance_of Rack::Response }

      it { expect(game_rack.win.location).to eq '/' }

      it { expect(game_rack.win.status).to eq 302 }
    end

    context 'when user is not win' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        game_manager.codebraker_game.instance_variable_set(:@stage, Codebraker::Settings::WIN)
        allow(game_manager).to receive(:win_codition?).and_return(false)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.win).to be_instance_of Rack::Response }

      it { expect(game_rack.win.status).to eq 200 }
    end

    context 'when user win' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(game_manager).to receive(:win_codition?).and_return(true)
        game_rack.instance_variable_set(:@game_manager, game_manager)
        game_manager.codebraker_game.instance_variable_set(:@stage, Codebraker::Settings::WIN)
      end

      it { expect(game_rack.win).to be_instance_of Rack::Response }

      it { expect(game_rack.win.status).to eq 200 }
    end
  end

  describe '#game' do
    context 'when codebreaker game is not in session' do
      it { expect(game_rack.game).to be_instance_of Rack::Response }

      it { expect(game_rack.game.location).to eq '/' }

      it { expect(game_rack.game.status).to eq 302 }
    end

    context 'when codebreaker game in session' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(game_manager).to receive(:matrix).and_return([])
        allow(game_manager).to receive(:hints).and_return([])
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.game).to be_instance_of Rack::Response }

      it { expect(game_rack.game.status).to eq 200 }
    end
  end

  describe '#hint' do
    context 'when codebreaker game is not in session' do
      it { expect(game_rack.hint).to be_instance_of Rack::Response }

      it { expect(game_rack.hint.location).to eq '/' }

      it { expect(game_rack.hint.status).to eq 302 }
    end

    context 'when codebreaker game in session' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(game_manager).to receive_message_chain(:codebraker_game, :check_for_hints?).and_return(false)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.hint).to be_instance_of Rack::Response }

      it { expect(game_rack.hint.status).to eq 302 }
    end
  end

  describe '#guess' do
    let(:guess) { '11111' }

    context 'when codebreaker game is not in session' do
      it { expect(game_rack.guess).to be_instance_of Rack::Response }

      it { expect(game_rack.guess.location).to eq '/' }

      it { expect(game_rack.guess.status).to eq 302 }
    end

    context 'when params is not given' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(request).to receive(:params).and_return({})
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.guess).to be_instance_of Rack::Response }

      it { expect(game_rack.guess.status).to eq 302 }
    end

    context 'when user is lose' do
      before do
        game_manager.codebraker_game.instance_variable_set(:@stage, Codebraker::Settings::IN_GAME)
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(request).to receive(:params).and_return({ 'number' => guess })
        allow(game_manager).to receive(:configure_game_session)
        allow(game_manager).to receive_message_chain(:codebraker_game, :check_for_attempts?).and_return(false)
        allow(game_manager).to receive_message_chain(:codebraker_game, :win?).and_return(false)
        allow(game_manager).to receive_message_chain(:codebraker_game, :lose?).and_return(true)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.guess).to be_instance_of Rack::Response }

      it { expect(game_rack.guess.status).to eq 302 }
    end

    context 'when user is win' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(request).to receive(:params).and_return({ 'number' => guess })
        allow(game_manager).to receive(:configure_game_session)
        allow(game_manager).to receive_message_chain(:codebraker_game, :check_for_attempts?).and_return(true)
        allow(game_manager).to receive_message_chain(:codebraker_game, :win?).and_return(true)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.guess).to be_instance_of Rack::Response }

      it { expect(game_rack.guess.status).to eq 302 }
    end

    context 'when the user did not guess' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
        allow(request).to receive(:params).and_return({ 'number' => guess })
        allow(game_manager).to receive(:configure_game_session)
        allow(game_manager).to receive_message_chain(:codebraker_game, :check_for_attempts?).and_return(true)
        allow(game_manager).to receive_message_chain(:codebraker_game, :win?).and_return(false)
        allow(game_manager).to receive_message_chain(:codebraker_game, :lose?).and_return(false)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.guess).to be_instance_of Rack::Response }

      it { expect(game_rack.guess.status).to eq 302 }
    end
  end

  describe '#index' do
    context 'when codebreaker game in session' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(true)
      end

      it { expect(game_rack.index).to be_instance_of Rack::Response }

      it { expect(game_rack.index.location).to eq '/game' }

      it { expect(game_rack.index.status).to eq 302 }
    end

    context 'when params is empty' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(false)
        allow(request).to receive(:params).and_return({})
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.index).to be_instance_of Rack::Response }

      it { expect(game_rack.index.status).to eq 200 }
    end

    context 'when params is not empty' do
      before do
        allow(game_manager).to receive(:game_exists?).and_return(false)
        allow(request).to receive_message_chain(:params, :empty?).and_return(false)
        allow(game_manager).to receive(:configure_codebraker_game)
        allow(game_manager).to receive(:clear_game_data_session)
        game_rack.instance_variable_set(:@game_manager, game_manager)
      end

      it { expect(game_rack.index).to be_instance_of Rack::Response }

      it { expect(game_rack.index.status).to eq 302 }
    end
  end
end
