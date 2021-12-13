# frozen_string_literal: true

require 'bundler'
Bundler.setup(:default)
require 'codebraker'
require 'i18n'
I18n.load_path << Dir[['config', 'locales', '**', '*.yml'].join('/')]
I18n.config.available_locales = :en
require 'haml'
require 'delegate'
require 'pry'
require 'rack'
require 'rack/test'
require_relative 'app/web_actions'
require_relative 'app/services/session_saver'
require_relative 'app/app_config'
require_relative 'app/services/output_helper'
require_relative 'app/game/game'
require_relative 'app/rackers/racker'
require_relative 'app/rackers/game_rack'
require_relative 'app/rackers/rules_rack'
require_relative 'app/rackers/statistics_rack'
require_relative 'app/app'
