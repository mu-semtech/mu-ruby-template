source 'https://rubygems.org'

gem 'sinatra', '1.4.7'

gem 'bson', '4.0.0'
gem 'rdf', '1.99.1'
gem 'rdf-vocab', '~> 0.8.7'
gem 'sparql-client', '1.99.0', require: 'sparql/client'

group :test, :development do
	gem 'rspec', '~> 3.4'
	gem 'json_spec', '~> 1.1', '>= 1.1.4'
	gem 'rack-test', '~> 0.6.3'
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end
