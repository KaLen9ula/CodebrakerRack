class App
  include WebActions
  MIDDLEWARES = [GameRack, RulesRack, StatisticsRack].freeze

  def self.call(env)
    new(env).response.finish
  end

  def response
    path = @request.path
    MIDDLEWARES.each do |middleware|
      return middleware.new(@request).response if middleware::ROUTES.key?(path)
    end
    redirect('/')
  end

  private

  def initialize(env)
    @request = Rack::Request.new(env)
  end
end
