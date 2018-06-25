require 'sparql/client'

module SinatraTemplate
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
        headers['MU_SESSION_ID'] = RequestStore.store[:mu_session_id]
        headers['MU_CALL_ID'] = RequestStore.store[:mu_call_id]
        headers['MU_AUTH_ALLOWED_GROUPS'] = RequestStore.store[:mu_auth_allowed_groups]
        headers['MU_AUTH_USED_GROUPS'] = RequestStore.store[:mu_auth_used_groups]
        response = super
        RequestStore.store[:mu_auth_allowed_groups] = response['MU_AUTH_ALLOWED_GROUPS']
        RequestStore.store[:mu_auth_used_groups] = response['MU_AUTH_USED_GROUPS']
        response
      end
    end
  end
end
