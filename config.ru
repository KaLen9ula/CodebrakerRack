# frozen_string_literal: true

require_relative 'autoloader'

use Rack::Reloader
use Rack::Static, urls: ['/assets'], root: 'views'
use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'

run App
