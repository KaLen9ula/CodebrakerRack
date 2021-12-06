# frozen_string_literal: true

module SessionSaver
  STORAGE_PATH = 'id.yml'
  STORAGE_DIRECTORY = 'app/services/session_id'

  def save_session(codebraker_game)
    create_storage unless storage_exists?
    store = YAML::Store.new(storage_path)
    session_id = generate_session_id
    store.transaction do
      store[session_id] = codebraker_game
    end
    session_id
  end

  def load_session(session_id)
    YAML.load_file(storage_path)[session_id]
  end

  private

  def create_storage
    Dir.mkdir(STORAGE_DIRECTORY) unless Dir.exist?(STORAGE_DIRECTORY)
    unless File.exist?(storage_path)
      new_file = YAML::Store.new(storage_path)
      new_file.transaction do
        new_file[session_id] = []
      end
    end
    YAML.load_file(storage_path)
  end

  def storage_path
    File.join(STORAGE_DIRECTORY, STORAGE_PATH)
  end

  def storage_exists?
    Dir.exist?(STORAGE_DIRECTORY) && File.exist?(storage_path)
  end

  def generate_session_id
    Array.new(6).map { ('a'..'z').to_a }.join
  end
end
