# frozen_string_literal: true

module SessionSaver
  STORAGE_PATH = 'app/services/session_id/id.yml'

  def save_session(codebraker_game)
    store = YAML::Store.new(STORAGE_PATH)
    session_id = generate_session_id
    store.transaction do
      store[session_id] = codebraker_game
    end
    session_id
  end

  def load_session(session_id)
    YAML.load_file(STORAGE_PATH)[session_id]
  end

  private

  def generate_session_id
    Array.new(6).map { ('a'..'z').to_a }.join
  end
end
