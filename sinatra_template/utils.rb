require_relative '../mu.rb'

module SinatraTemplate
  module Utils
    # Forward all util functions to Mu-module
    [:log,
     :update_modified,
     :generate_uuid,
     :graph,
     :query,
     :sparql_client,
     :update,
     :sparql_escape_datetime,
     :sparql_escape_string,
     :sparql_escape_uri,
     :sparql_escape_int,
     :sparql_escape_float,
     :sparql_escape_bool,
     :sparql_escape_date].each do |method|
      define_method(method) do |*args, &block|
        Mu.log.warn "[DEPRECATION] #{SinatraTemplate::Utils.name}.#{__callee__} is deprecated. Please use #{Mu.name}.#{__method__} instead."
        Mu.send(method, *args, &block)
      end
      module_function(method)
    end
  end
end
