require 'bson'
require 'logger'
require 'rdf/vocab'
require 'uri'
require_relative '../lib/escape_helpers.rb'
require_relative 'sparql/client.rb'

module SinatraTemplate
  module Utils

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
        @log.level = Kernel.const_get("Logger::#{ENV['LOG_LEVEL'].upcase}")
      end
      @log
    end

    def query(query)
      log.info "Executing query: #{query}"
      sparql_client.query query
    end

    def sparql_client
      options = {}
      if ENV['MU_SPARQL_TIMEOUT']
        options[:read_timeout] = ENV['MU_SPARQL_TIMEOUT'].to_i
      end
      SinatraTemplate::SPARQL::Client.new(ENV['MU_SPARQL_ENDPOINT'], **options)
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

    def update(query)
      log.info "Executing query: #{query}"
      sparql_client.update query
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

  end

end
