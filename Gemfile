source 'https://rubygems.org'

gem 'sinatra', '1.4.7'

gem 'bson', '4.1.1'
gem 'rdf', '2.0.1'
gem 'rdf-vocab', '2.0.1'
gem 'sparql-client', '2.0.0', require: 'sparql/client'

group :test, :development do
 gem 'rspec', '~> 3.4'
 gem 'json_spec', '~> 1.1', '>= 1.1.4'
 gem 'rack-test', '~> 0.6.3'
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end