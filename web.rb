require 'sinatra'
require 'logger'
require 'sparql/client'
require 'json'
require 'rdf/vocab'
require 'bson'
require_relative 'sinatra_template/helpers.rb'

configure do
  set :graph, ENV['MU_APPLICATION_GRAPH']
  set :sparql_client, SPARQL::Client.new(ENV['MU_SPARQL_ENDPOINT'])

  ###
  # Logging
  ###
  log_dir = '/logs'
  Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
  # Keep 10 log files of 100 MB in size
  log = Logger.new("#{log_dir}/#{settings.environment}.log", 10, 100*1024*1024)
  log.level = Kernel.const_get("Logger::#{ENV['LOG_LEVEL'].upcase}")
  set :log, log
end

###
# Vocabularies
###

include RDF
MU = RDF::Vocabulary.new('http://mu.semte.ch/vocabularies/')
MU_CORE = RDF::Vocabulary.new(MU.to_uri.to_s + 'core/')
MU_EXT = RDF::Vocabulary.new(MU.to_uri.to_s + 'ext/')

###
# Helpers
###

helpers SinatraTemplate::Helpers
app_file = ENV['APP_ENTRYPOINT']
require_relative "ext/#{app_file}"
