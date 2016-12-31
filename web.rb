require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'better_errors' if development?
require 'json'
require 'rdf/vocab'
require_relative 'sinatra_template/helpers.rb'
require_relative 'sinatra_template/utils.rb'

include SinatraTemplate::Utils

configure do
  set :graph, graph
  set :sparql_client, sparql_client
  set :update_endpoint, update_endpoint
  set :log, SinatraTemplate::Utils.log
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


app_file = ENV['APP_ENTRYPOINT']
require_relative "ext/#{app_file}"
