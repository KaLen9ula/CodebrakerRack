require 'bundler'
Bundler.setup(:default)
require 'codebraker'
require 'i18n'
I18n.load_path << Dir[['config', 'locales', '**', '*.yml'].join('/')]
I18n.config.available_locales = :en
require 'delegate'
require 'pry'
require 'rack'
require 'rack/test'
require 'haml'
require_relative 'app/web_actions'
require_relative 'app/rackers/racker'
require_relative 'app/game/game'
require_relative 'app/rackers/game_rack'
require_relative 'app/rackers/rules_rack'
require_relative 'app/rackers/statistics_rack'
require_relative 'app/app'
