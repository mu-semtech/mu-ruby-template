require_relative '../mu.rb'

module SinatraTemplate

  def self.methods_to_forward
    [
      :log,
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
      :sparql_escape_date
    ]
  end

  module Utils
    # Forward all util functions to Mu-module
    SinatraTemplate::methods_to_forward.each do |method|
      define_method(method) do |*args, &block|
        Mu::log.info "[DEPRECATION] #{SinatraTemplate::Utils.name}.#{__callee__} is deprecated. Please use #{Mu.name}::#{__method__} instead." if Mu.truthy? ENV['PRINT_DEPRECATION_WARNINGS']
        Mu.send(method, *args, &block)
      end
      module_function(method)
    end
  end

  module GlobalUtils
    # Forward all util functions to Mu-module
    SinatraTemplate::methods_to_forward.each do |method|
      define_method(method) do |*args, &block|
        Mu::log.info "[DEPRECATION] #{__method__} is deprecated. Please use #{Mu.name}::#{__method__} instead." if Mu.truthy? ENV['PRINT_DEPRECATION_WARNINGS']
        Mu.send(method, *args, &block)
      end
      module_function(method)
    end
  end
end
