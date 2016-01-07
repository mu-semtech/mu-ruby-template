source 'https://rubygems.org'

gem 'sinatra'

gem 'json'
gem 'rdf'
gem 'sparql-client', require: 'sparql/client'

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
