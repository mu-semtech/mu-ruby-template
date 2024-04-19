require 'bson'
require 'logger'
require 'uri'
require 'sparql/client'
require_relative 'lib/escape_helpers.rb'

module Mu
  # provide methods also as class methods on the module
  extend self

  def generate_uuid
    BSON::ObjectId.new.to_s
  end

  def graph
    ENV['MU_APPLICATION_GRAPH']
  end

  def log
    if @log.nil?
      log_dir = '/logs'
      Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
      @log = Logger.new("#{log_dir}/application.log")
      @log.level = Logger.const_get(ENV['LOG_LEVEL'].upcase)
    end
    @log
  end

  def query(query, **options)
    log.info "Executing query: #{query}"
    @sparql_client = sparql_client(**options)
    @sparql_client.query query
  end

  def sparql_client(**options)
    if Mu::truthy? options[:sudo]
      if Mu::truthy? ENV['ALLOW_MU_AUTH_SUDO']
        options[:headers] = { 'mu-auth-sudo': 'true' }
      else
        log.error "Error, sudo request but service lacks ALLOW_MU_AUTH_SUDO header"
      end
    end
    if options[:scope]
      options[:headers] = { 'mu-auth-sudo': options[:scope] }
    elsif ENV['DEFAULT_MU_AUTH_SCOPE']
      options[:headers] = { 'mu-auth-sudo': ENV['DEFAULT_MU_AUTH_SCOPE'] }
    end
    if ENV['MU_SPARQL_TIMEOUT']
      options[:read_timeout] = ENV['MU_SPARQL_TIMEOUT'].to_i
    end
    Mu::SPARQL::Client.new(ENV['MU_SPARQL_ENDPOINT'], **options)
  end

  def sparql_escape_string(value)
    value ? value.to_s.sparql_escape : value
  end

  def sparql_escape_uri(value)
    value ? URI.parse(value).sparql_escape : value
  end

  def sparql_escape_int(value)
    value ? value.to_i.sparql_escape : value
  end

  def sparql_escape_float(value)
    value ? value.to_f.sparql_escape : value
  end

  def sparql_escape_bool(value)
    value ? true.sparql_escape : false.sparql_escape
  end

  def sparql_escape_date(value)
    value ? Date.parse(value).sparql_escape : value
  end

  def sparql_escape_datetime(value)
    value ? DateTime.parse(value).sparql_escape : value
  end

  def truthy? value
    ["true", "yes", "1"].include?(value && value.to_s.downcase)
  end

  def update(query, **options)
    log.info "Executing query: #{query}"
    @sparql_client = sparql_client(**options)
    @sparql_client.update query
  end

  def update_modified(subject, modified = DateTime.now)
    query =  " WITH <#{graph}> "
    query += " DELETE {"
    query += "   <#{subject}> <#{RDF::Vocab::DC.modified}> ?modified ."
    query += " }"
    query += " WHERE {"
    query += "   <#{subject}> <#{RDF::Vocab::DC.modified}> ?modified ."
    query += " }"
    update(query)

    query =  " INSERT DATA {"
    query += "   GRAPH <#{graph}> {"
    query += "     <#{subject}> <#{RDF::Vocab::DC.modified}> #{modified.sparql_escape} ."
    query += "   }"
    query += " }"
    update(query)
  end

  module Helpers
    # provide methods also as class methods on the module
    extend self

    def session_id_header(request)
      Mu::log.debug "Get HTTP_MU_SESSION_ID request header from #{request.env.inspect}"
      request.env['HTTP_MU_SESSION_ID']
    end

    def rewrite_url_header(request)
      Mu::log.debug "Get HTTP_X_REWRITE_URL request header from #{request.env.inspect}"
      request.env['HTTP_X_REWRITE_URL']
    end

    def error(title, status = 400)
      Mu::log.error "HTTP status #{status}: #{title}"
      halt status, { errors: [{ title: title }] }.to_json
    end

    def validate_json_api_content_type(request)
      error("Content-Type must be application/vnd.api+json instead of #{request.env['CONTENT_TYPE']}.") if not request.env['CONTENT_TYPE'] =~ /^application\/vnd\.api\+json/
    end

    def validate_resource_type(expected_type, data)
      error("Incorrect type. Type must be #{expected_type}, instead of #{data['type']}.", 409) if data['type'] != expected_type
    end
  end

  module SPARQL
    class Client < ::SPARQL::Client
      ##
      # Performs an HTTP request against the SPARQL endpoint.
      #
      # @param  [String, #to_s]          query
      # @param  [Hash{String => String}] headers
      # @yield  [response]
      # @yieldparam [Net::HTTPResponse] response
      # @return [Net::HTTPResponse]
      # @see    http://www.w3.org/TR/sparql11-protocol/#query-operation
      def request(query, headers = {}, &block)
        headers['mu-session-id'] = RequestStore.store[:mu_session_id]
        headers['mu-call-id'] = RequestStore.store[:mu_call_id]
        headers['mu-auth-allowed-groups'] = RequestStore.store[:mu_auth_allowed_groups]
        headers['mu-auth-used-groups'] = RequestStore.store[:mu_auth_used_groups]
        response = super
        RequestStore.store[:mu_auth_allowed_groups] = response['mu-auth-allowed-groups']
        RequestStore.store[:mu_auth_used_groups] = response['mu-auth-used=groups']
        response
      end
    end
  end
end
