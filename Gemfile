source 'https://rubygems.org'

gem 'sinatra'

gem 'bson'
gem 'json'
gem 'rdf'
gem 'rdf-vocab'
gem 'sparql-client', require: 'sparql/client'

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
