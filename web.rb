require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'better_errors' if development?
require 'json'
require 'rdf/vocab'
require 'request_store'
require_relative 'sinatra_template/helpers.rb'
require_relative 'sinatra_template/utils.rb'

include SinatraTemplate::Utils

configure do
  # backwards compatibility
  set :graph, graph
  set :sparql_client, sparql_client
  set :update_endpoint, update_endpoint
  set :log, SinatraTemplate::Utils.log
  
  set :protection, :except => [:json_csrf]
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
  # you need to set the application root in order to abbreviate filenames within the application:
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
helpers SinatraTemplate::Helpers
use RequestStore::Middleware

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
    auth_headers['mu-auth-allowed-groups'] = RequestStore.store[:mu_auth_allowed_groups]
  end
  if RequestStore.store[:mu_auth_used_groups]
    auth_headers['mu-auth-used-groups'] = RequestStore.store[:mu_auth_used_groups]
  end
  headers auth_headers
end

###
# Include extension code
###
app_file = ENV['APP_ENTRYPOINT']
require_relative "ext/#{app_file}"
