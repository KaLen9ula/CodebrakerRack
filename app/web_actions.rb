# frozen_string_literal: true

module WebActions
  TEMPLATE_PATH = '../../views/'
  TEMPLATE_FORMAT = '.html.haml'
  BASE_TEMPLATE = 'base'

  def redirect(name)
    Rack::Response.new { |response| response.redirect(name) }
  end

  def rack_response(name)
    Rack::Response.new(render_template(BASE_TEMPLATE) { render_template(name) })
  end

  def render_template(name)
    path = File.expand_path("#{TEMPLATE_PATH}#{name}#{TEMPLATE_FORMAT}", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end
end
