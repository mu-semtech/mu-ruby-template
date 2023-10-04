# Mu Ruby template
Template for running Ruby/[Sinatra](http://www.sinatrarb.com/) microservices

## Getting started
### How to use the template
Create a new folder. Add the following Dockerfile
```
FROM semtech/mu-ruby-template
LABEL maintainer="john.doe@example.com"
# ONBUILD of mu-ruby-template takes care of everything
```
Create your microservice in `web.rb`:
```ruby
get '/' do
  status 200
  {
    message: "Hello world!"
  }.to_json
end

get '/triples' do
  solutions = Mu::query("SELECT * WHERE { ?s ?p ?o }")
  triples = solutions.map do |solution|
    {
      subject: solution[:s],
      predicate: solution[:p],
      object: solution[:o]
    }
  end
  status 200
  {
    data: triples
  }.to_json
end
```
### How to install additional dependencies
You can use the Gemfile as you would expect. Just create a `Gemfile` in the root folder of your service containing the additional dependencies. The file will be automatically picked up and the dependencies will be installed.

Dependencies that are installed by default can be found in the [template's Gemfile](./Gemfile).

### How to develop with the template in an application stack
Live reload is enabled automatically when running in development mode.  You can embed the template easily in a running mu.semte.ch stack by launching it in the `docker-compose.yml` with the correct links.

When developing inside an existing mu.semte.ch stack, you can use the template image, mount the volume with your sources in `/app` and add a link to the database. Set the `RACK_ENV` environment variable to `development`. The service will now live reload on changes. You'll need to restart the container when you define additional dependencies in your `Gemfile`.

Optionally, you can publish the microservice on a different port, so you can access it directly without the dispatcher.  In the example below, port 8888 is used to access the service directly. We set the path to our sources directly, ensuring we can develop the microservice in its original place.

```yml
my-ruby-service:
  image: semtech/mu-ruby-template
  ports:
    - 8888:80
  environment:
    RACK_ENV: "development"
  links:
    - db:database
  volumes:
    - /absolute/path/to/your/sources/:/app/
```

### How to debug
If desired, [debug](https://rubygems.org/gems/debug) and [Better Errors](https://rubygems.org/gems/better_errors) can be used during development, giving advanced ruby debugging features.

#### Better Errors
When an error occurs, an interactive [Better Errors](https://github.com/charliesome/better_errors) error page is available at `http://{container-ip}/__better_errors`. It's important to access the error page via the container's IP directly and not through localhost, identifier, dispatcher, etc.

#### Attach the debugger
When running in development mode, you can attach the debugger to your microservice and add breakpoints as you're used to. The debugger requires port 12345 to be forwarded, and your service to run in development mode.

```yml
my-ruby-service:
  image: semtech/mu-ruby-template
  ports:
    - 8888:80
    - 12345:12345
  environment:
    RACK_ENV: "development"
  links:
    - db:database
  volumes:
    - /absolute/path/to/your/sources/:/app/
```

Currently 2 debuggers are supported which can be configured via the `RUBY_DEBUG_OPEN_FRONTEND` environment variable:
- `rdbg` (default)
- `chrome`

##### rdbg
Add a breakpoint in your code by inserting a `binding.break` (alias `debugger`, `binding.b`) statement.

Attach the default ruby debugger tool by starting a new interactive container using the following command:

```bash
docker run --rm semtech/mu-ruby-template rdbg --attach 12345
```

The code will run until the breakpoint is reached. Use the debugger tool as documented in the [ruby debug documentation](https://github.com/ruby/debug#invoke-with-the-debugger) to inspect your code.

##### Chrome DevTools
Configure `chrome` as debugger frontend by adding the following environment variable on your service
```yml
  environment:
    RACK_ENV: "development"
    RUBY_DEBUG_OPEN_FRONTEND: "chrome"
```

Add a breakpoint in your code by inserting a `binding.break` (alias `debugger`, `binding.b`) statement.

After launching your service, open Google Chrome or Chromium and visit [devtools://devtools/bundled/inspector.html?ws=127.0.0.1:12345](devtools://devtools/bundled/inspector.html?ws=127.0.0.1:12345). Once you reach the breakpoint, the file containing your code will be automatically opened in the 'Sources' tab.

### How to run tests

**TODO To be reviewed**

To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment  with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=test
                -it semtech/mu-ruby-template:2.11.1 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec

## Reference
### Utils
The template provides a `Mu` module with utils to facilitate development
#### Mu::graph
Returns the application graph configured through the `MU_APPLICATION_GRAPH`.

#### Mu::generate_uuid()
Generate a random UUID (String).

#### Mu::log
The template provides a [Logger](https://ruby-doc.org/stdlib-2.3.0/libdoc/logger/rdoc/Logger.html) `log` object to the user for logging. Just do `Mu::log.info "Hello world"`. The log level can be set through the `LOG_LEVEL` environment variable (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).

Logs are written to the `/logs` directory and `STDOUT` in the docker container.

#### Mu::query(query)
Executes the given SPARQL select/ask/construct query.

#### Mu::sparql_client
Returns a SPARQL::Client instance connection to the SPARQL endpoint configured through the `MU_SPARQL_ENDPOINT` environment variable.

#### *.sparql_escape ; Mu::sparql_escape_{string|uri|date|datetime|bool|int|float}(value)
The Ruby templates extends the core classes `String`, `Date`, `DateTime`, `Time`, `Integer`, `Float`, `Boolean` and `URI` with a `sparql_escape` method. This method can be used to avoid SPARQL injection by escaping user input while constructing a SPARQL query. E.g.

```ruby
query =  " INSERT DATA {"
query += "   GRAPH <#{Mu::graph}> {"
query += "     #{Mu::sparql_escape_uri(user_uri)} a <#{RDF::Vocab::FOAF.Person}> ;"
query += "                   <#{RDF::Vocab::FOAF.name}> #{name.sparql_escape} ;"
query += "                   <#{RDF::Vocab::DC.created}> #{now.sparql_escape} ."
query += "   }"
query += " }"
```

Next to the extensions, the template also provides a helper function per datatype that takes any value as parameter. E.g. `Mu::sparql_escape_uri("http://mu.semte.ch/application")`.

#### update(query)
Executes the given SPARQL update query.

#### update_modified(subject, modified = DateTime.now)
Executes a SPARQL query to update the modification date of the given subject URI (string). The date defaults to now.


### Sinatra helpers
The template provides the following Sinatra helpers which can only be used in a route-handling context:

#### @json_body
The parsed JSON body of the request.

#### error(title, status = 400)
Returns a JSONAPI compliant error response with the given status code (default: `400`).

#### rewrite_url_header(request)
Get the rewrite URL from the request headers.

#### session_id_header(request)
Get the session id from the request headers.

#### validate_json_api_content_type(request)
Validate whether the Content-Type header contains the JSONAPI Content-Type. Returns a `400` otherwise.

#### validate_resource_type(expected_type, data)
Validate whether the type specified in the JSON data is equal to the expected type. Returns a `409` otherwise.

### Environment variables
The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT`: SPARQL endpoint URL. Default: `http://database:8890/sparql`
- `MU_SPARQL_TIMEOUT`: timeout (in seconds) for SPARQL queries. Default: 60 seconds.
- `LOG_LEVEL`: the level of logging (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).
- `USE_LEGACY_UTILS`: when enabled (using `"true"` or `"yes"`) legacy utils from v2 will be included in the root file so they can be used as before (e.g. `query` instead of `Mu::query`). Default: `"true"`
- `PRINT_DEPRECATION_WARNINGS`: Deprecation warnings will be printed for each usage of a legacy util. Default: `"true"`.
- `RACK_ENV`: environment to start the Sinatra application in. Default: `production`. Possible values `production`, `development`, `test`.
- `APP_ENTRYPOINT`: name of the file containing the application entrypoint. Default: `web.rb`.
- `RUBY_DEBUG_PORT`: port to use for remote debugging. Default: `12345`.
- `RUBY_DEBUG_OPEN_FRONTEND`: frontend to use for debugging. Default: `rdbg`. Possible values: `rdbg`, `chrome`.
- `RUBY_OPTIONS`: options to pass to the ruby command on startup. Default: `--jit`.

### Custom build commands
To execute custom bash statements during the image build (e.g. to install aditional system libraries), provide an `on-build.sh` script in the root of your service. It will be automatically picked up and executed by the Docker build.
