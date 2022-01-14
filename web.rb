require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'linkeddata'
require 'request_store'
if development?
  require 'sinatra/reloader'
  require 'better_errors'
end
require_relative 'sinatra_template/helpers.rb'
require_relative 'sinatra_template/utils.rb'
require_relative 'mu.rb'

configure do
  set :environment, ENV['RACK_ENV'].downcase.to_sym
  set :bind, '0.0.0.0'
  set :port, 80
  set :protection, :except => [:json_csrf]
end

if development?
  mounted_volume = '/app'
  if not File.directory?(mounted_volume) or not File.exist?("#{mounted_volume}/#{ENV['APP_ENTRYPOINT']}")
    Mu.log.warn "Template is started in development mode, but no sources are mounted in #{mounted_volume}. Expected a file at #{mounted_volume}/#{ENV['APP_ENTRYPOINT']}."
    exit(1)
  end
  also_reload "#{mounted_volume}/**/*"
  after_reload do
    Mu.log.info "Changes detected. Reloaded the app."
  end

  use BetterErrors::Middleware
  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
  # set the application root in order to abbreviate filenames within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end


###
# Vocabularies
###
include RDF
MU = RDF::Vocabulary.new('http://mu.semte.ch/vocabularies/')
MU_CORE = RDF::Vocabulary.new(MU.to_uri.to_s + 'core/')
MU_EXT = RDF::Vocabulary.new(MU.to_uri.to_s + 'ext/')

SERVICE_RESOURCE_BASE = 'http://mu.semte.ch/services/'


###
# Helpers
###
helpers Mu::Helpers
use RequestStore::Middleware

if Mu.truthy? ENV['INCLUDE_LEGACY_UTILS']
  Mu.log.info "INCLUDE_LEGACY_UTILS enabled. Deprecated utilities will be included. Upgrade by using utils from the Mu-module instead. E.g. 'query' becomes 'Mu.query'"
  include SinatraTemplate::Utils
end

###
# Hooks
###
before do
  begin
    request.body.rewind
    @json_body = JSON.parse request.body.read
  rescue
    # request doesn't have a JSON body. Do nothing.
  end
  begin
    if session_id_header(request)
      RequestStore.store[:mu_session_id] = session_id_header(request)
      RequestStore.store[:mu_call_id] = request.env['HTTP_MU_CALL_ID']
      RequestStore.store[:mu_auth_allowed_groups] = request.env['HTTP_MU_AUTH_ALLOWED_GROUPS']
      RequestStore.store[:mu_auth_used_groups] = request.env['HTTP_MU_AUTH_USED_GROUPS']
    end
  rescue Exception => e
    log.error e
  end
end

after do
  auth_headers = {}
  if RequestStore.store[:mu_auth_allowed_groups]
    if headers['mu-auth-allowed-groups']
      log.info "ruby template: not setting allowed groups because header already provided with value #{headers['mu-auth-allowed-groups'].inspect}"
    else
      auth_headers['mu-auth-allowed-groups'] = RequestStore.store[:mu_auth_allowed_groups]
    end
  end
  if RequestStore.store[:mu_auth_used_groups]
    if headers['mu-auth-used-groups']
      log.info "ruby template: not setting used groups because header already provided with value #{headers['mu-auth-used-groups'].inspect}"
    else
      auth_headers['mu-auth-used-groups'] = RequestStore.store[:mu_auth_used_groups]
    end
  end
  headers auth_headers
end

###
# Include extension code
###
app_file = ENV['APP_ENTRYPOINT']
require_relative "ext/#{app_file}"
