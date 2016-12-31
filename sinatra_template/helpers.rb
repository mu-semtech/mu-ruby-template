require 'bson'
require 'logger'
require 'sparql/client'
require_relative './utils.rb'

module SinatraTemplate
  module Helpers

    def session_id_header(request)
      SinatraTemplate::Utils.log.debug "Get HTTP_MU_SESSION_ID request header from #{request.env.inspect}"
      request.env['HTTP_MU_SESSION_ID']
    end
  
    def rewrite_url_header(request)
      SinatraTemplate::Utils.log.debug "Get HTTP_X_REWRITE_URL request header from #{request.env.inspect}"
      request.env['HTTP_X_REWRITE_URL']
    end
  
    def error(title, status = 400)
      SinatraTemplate::Utils.log.error "HTTP status #{status}: #{title}"
      halt status, { errors: [{ title: title }] }.to_json
    end
  
    def validate_json_api_content_type(request)
      error("Content-Type must be application/vnd.api+json instead of #{request.env['CONTENT_TYPE']}.") if not request.env['CONTENT_TYPE'] =~ /^application\/vnd\.api\+json/
    end
  
    def validate_resource_type(expected_type, data)
      error("Incorrect type. Type must be #{expected_type}, instead of #{data['type']}.", 409) if data['type'] != expected_type
    end

  end
end
