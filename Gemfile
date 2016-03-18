source 'https://rubygems.org'

gem 'sinatra', '1.4.6'
gem 'bson', '4.0.0'
gem 'multi_json', '~> 1.11'
gem 'jrjackson', '~> 0.3.8', platforms: :jruby
gem 'oj', '~> 2.14', platforms: :ruby
gem 'rdf', '1.99.1'
gem 'rdf-vocab', '~> 0.8.7'
gem 'sparql-client', '1.99.0', require: 'sparql/client'
gem 'rake'

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
