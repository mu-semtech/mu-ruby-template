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
