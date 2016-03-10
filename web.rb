require 'sinatra'
require 'logger'
require 'sparql/client'
require 'json'
require 'rdf/vocab'
require 'bson'

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

###
# Helpers
###

helpers do

  def generate_uuid
    BSON::ObjectId.new.to_s
  end

  def log
    settings.log
  end

  def session_id_header(request)
    log.debug "Get HTTP_MU_SESSION_ID request header from #{request.env.inspect}"
    request.env['HTTP_MU_SESSION_ID']
  end

  def rewrite_url_header(request)
    log.debug "Get HTTP_X_REWRITE_URL request header from #{request.env.inspect}"
    request.env['HTTP_X_REWRITE_URL']
  end

  def error(title, status = 400)
    log.error "HTTP status #{status}: #{title}"
    halt status, { errors: [{ title: title }] }.to_json
  end

  def validate_json_api_content_type(request)
    error("Content-Type must be application/vnd.api+json instead of #{request_env['CONTENT_TYPE']}.") if not request.env['CONTENT_TYPE'] == 'application/vnd.api+json'
  end

  def validate_resource_type(expected_type, data)
    error("Incorrect type. Type must be #{expected_type}, instead of #{data['type']}.", 409) if data['type'] != expected_type
  end

  def query(query)
    log.info "Executing query: #{query}"
    settings.sparql_client.query query
  end

  def update(query)
    log.info "Executing query: #{query}"
    settings.sparql_client.update query
  end

  def update_modified(subject, modified = DateTime.now.xmlschema)
    query =  " WITH <#{settings.graph}> "
    query += " DELETE {"
    query += "   <#{subject}> <#{RDF::Vocab::DC.modified}> ?modified ."
    query += " }"
    query += " WHERE {"
    query += "   <#{subject}> <#{RDF::Vocab::DC.modified}> ?modified ."
    query += " }"
    update(query)

    query =  " INSERT DATA {"
    query += "   GRAPH <#{settings.graph}> {"
    query += "     <#{subject}> <#{RDF::Vocab::DC.modified}> \"#{modified}\"^^xsd:dateTime ."
    query += "   }"
    query += " }"
    update(query)
  end

end

app_file = ENV['APP_ENTRYPOINT']
require_relative "ext/#{app_file}"
