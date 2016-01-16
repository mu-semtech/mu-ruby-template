require 'sinatra'
require 'sparql/client'
require 'json'
require 'rdf/vocab'

configure do
  set :graph, ENV['MU_APPLICATION_GRAPH']
  set :sparql_client, SPARQL::Client.new('http://database:8890/sparql')
end


###
# Vocabularies
###

include RDF
MU = RDF::Vocabulary.new('http://mu.semte.ch/vocabularies/')

###
# Helpers
###

helpers do

  def session_id_header(request)
    request.env['HTTP_MU_SESSION_ID']
  end

  def rewrite_url_header(request)
    request.env['HTTP_X_REWRITE_URL']
  end

  def error(title, status = 400)
    halt status, { errors: [{ title: title }] }.to_json
  end

  def validate_json_api_content_type(request)
    error('Content-Type must be application/vnd.api+json') if not request.env['CONTENT_TYPE'] == 'application/vnd.api+json'
  end

  def validate_resource_type(expected_type, data)
    error("Incorrect type. Type must be #{data['type']}", 409) if data['type'] != expected_type
  end

  def query(query)
    settings.sparql_client.query query
  end

  def update(query)
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
    settings.sparql_client.update(query)

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
