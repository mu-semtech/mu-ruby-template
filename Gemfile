source 'https://rubygems.org'

gem 'sinatra', '~> 2.1'
gem 'sinatra-contrib', '~> 2.1'
gem 'webrick', '~> 1.8.2'
gem 'bson', '~> 4.0'
gem 'sparql-client', '~> 3.3'
gem 'rdf-vocab', '~> 3.3'
gem 'nokogiri', '~> 1.15'
gem 'request_store', '~> 1.4'

group :test, :development do
  gem 'rerun', '~> 0.14.0'
  gem 'rspec', '~> 3.10'
  gem 'json_spec', '~> 1.1'
  gem 'rack-test', '~> 1.1'
  gem 'debug', '~> 1.8', :platforms => :ruby
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0', :platforms => :ruby
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
