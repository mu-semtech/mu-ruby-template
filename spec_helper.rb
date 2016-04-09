require 'rack/test'
require 'rspec'
require 'json_spec'

require File.expand_path '../web.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include JsonSpec::Helpers
end
