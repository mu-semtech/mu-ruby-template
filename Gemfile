source 'https://rubygems.org'

gem 'sinatra', '~> 4.1'
gem 'sinatra-contrib', '~> 4.1'
gem 'rackup', '~> 2.2'
gem 'webrick', '~> 1.9'
gem 'bson', '~> 4.15'
gem 'sparql-client', '~> 3.3'
gem 'rdf-vocab', '~> 3.3'
gem 'nokogiri', '~> 1.18'
gem 'request_store', '~> 1.7'

group :test, :development do
  gem 'rerun', '~> 0.14.0'
  gem 'rspec', '~> 3.10'
  gem 'json_spec', '~> 1.1'
  gem 'rack-test', '~> 2.2'
  gem 'debug', '~> 1.8', :platforms => :ruby
  gem 'better_errors', '~> 2.10'
  gem 'binding_of_caller', '~> 1.0', :platforms => :ruby
  gem 'pry-debugger-jruby', '~> 2.1', :platforms => :jruby
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '**', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
