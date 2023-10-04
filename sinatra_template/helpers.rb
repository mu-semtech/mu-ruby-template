require_relative '../mu.rb'

module SinatraTemplate
  module Helpers
    # Forward all helpers to Mu::Helpers-module
    [:session_id_header,
     :rewrite_url_header,
     :error,
     :validate_json_api_content_type,
     :validate_resource_type].each do |method|
      define_method(method) do |*args, &block|
        Mu.log.warn "[DEPRECATION] #{SinatraTemplate::Helpers.name}.#{__callee__} is deprecated. Please use #{Mu::Helpers.name}.#{__method__} instead." if Mu.truthy? ENV['PRINT_DEPRECATION_WARNINGS']
        Mu::Helpers.send(method, *args, &block)
      end
      module_function(method)
    end
  end
end
