source 'https://rubygems.org'

gem 'sinatra', '1.4.6'

gem 'bson', '4.0.0'
gem 'json', '1.8.3'
gem 'rdf', '1.99.1'
gem 'rdf-vocab', '~> 0.8.7'
gem 'sparql-client', '1.99.0', require: 'sparql/client'

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
