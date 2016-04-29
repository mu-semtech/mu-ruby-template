module SinatraTemplate
  module Helpers
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
      error("Content-Type must be application/vnd.api+json instead of #{request.env['CONTENT_TYPE']}.") if not request.env['CONTENT_TYPE'] =~ /^application\/vnd\.api\+json/
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
    
    def escape_string_parameter (parameter)
      if parameter and parameter.is_a? String
        parameter.gsub(/[\\"']/){|s|'\\'+s}
      end
    end

    def verify_string_parameter (parameter)
      if parameter  and parameter.is_a? String
        raise "unauthorized insert in string parameter" if parameter.downcase.include? "insert"
        raise "unauthorized delete in string parameter" if parameter.downcase.include? "delete"
        raise "unauthorized load in string parameter" if parameter.downcase.include? "load"
        raise "unauthorized clear in string parameter" if parameter.downcase.include? "clear"
        raise "unauthorized create in string parameter" if parameter.downcase.include? "create"
        raise "unauthorized drop in string parameter" if parameter.downcase.include? "drop"
        raise "unauthorized copy in string parameter" if parameter.downcase.include? "copy"
        raise "unauthorized move in string parameter" if parameter.downcase.include? "move"
        raise "unauthorized add in string parameter" if parameter.downcase.include? "add"
      end
    end
  end
end
