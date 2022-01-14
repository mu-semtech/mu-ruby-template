require_relative '../../mu.rb'

module SinatraTemplate
  module SPARQL
    class Client
      # Forward all methods to Mu::SPARQL::Client
      Mu::SPARQL::Client.instance_methods.each do |method|
        define_method(method) do |*args, &block|
          Mu.log.warn "[DEPRECATION] #{SinatraTemplate::SPARQL::Client.name}.#{__callee__} is deprecated. Please use #{Mu::SPARQL::Client.name}.#{__method__} instead."
          Mu::SPARQL::Client.send(method, *args, &block)
        end
      end
    end
  end
end
