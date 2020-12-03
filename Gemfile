source 'https://rubygems.org'

gem 'sinatra', '1.4.8'
gem 'sinatra-contrib', '1.4.7'
gem 'thin', '1.7.0'

gem 'bson', '4.0.0'
gem 'rdf-vocab', '3.0.8'
gem 'sparql-client', '3.1.0'
gem 'request_store', '1.4.1'

group :test, :development do
  gem 'rspec', '~> 3.4'
  gem 'json_spec', '~> 1.1', '>= 1.1.4'
  gem 'rack-test', '~> 0.6.3'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms => :ruby
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
