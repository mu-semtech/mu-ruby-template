# Mu Ruby template
Template for writing semantic.works services in Ruby using [Sinatra](http://www.sinatrarb.com/)

## Tutorials
### Develop your first microservice
Requires: a semantic.works stack, like mu-project.

Create a new folder for your microservice.

In the folder, create your microservice in `web.rb`:

```ruby
get '/hello' do
  status 200
  {
    message: "Hello mu-ruby-template"
  }.to_json
end
```

This service will respond with 'Hello mu-ruby-template' when receiving a GET request on '/hello'.

Add the mu-ruby-template to your `docker-compose.yml` with the sources mounted directly.

```yml
version: '3.4'
services:
    your-microservice-name:
      image: semtech/mu-ruby-template:3.1.0
      environment:
        RACK_ENV: "development"
      ports:
        - 8888:80
      volumes:
        - /absolute/path/to/your/sources/:/app/
```

Next, create the service by running
```
docker-compose up -d your-microservice-name
```

A `curl` call to the microservice will show you to message

```bash
curl http://localhost:8888/hello
# Hello mu-ruby-template
```

## How-to
### Develop in a mu.semte.ch stack
Requires:
- a semantic.works stack, like mu-project
- 'Develop your first microservice'

When developing inside an existing mu.semte.ch stack, it is easiest to set the development mode by setting the `RACK_ENV` environment variable to `development` and mount the sources directly.  This makes it easy to setup links to the database and the dispatcher. Livereload is enabled automatically when running in development mode.

```yml
version: ...
services:
  ...
  your-microservice-name:
    image: semtech/mu-ruby-template:3.1.0
    environment:
      RACK_ENV: "development"
    volumes:
      - /absolute/path/to/your/sources/:/app/
```

### Build a microservice based on mu-ruby-template
Requires:
- a semantic.works stack, like mu-project
- 'Develop your first microservice'

Add a Dockerfile with the following contents:

```docker
FROM semtech/mu-ruby-template:3.1.0
LABEL maintainer="john.doe@example.com"
```

There are various ways to build a Docker image. For a production service we advise to setup automatic builds, but here we will build it locally. You can choose any name, but we will call ours 'say-hello-service'.

From the root of your microservice folder execute the following command:
```bash
docker build -t say-hello-service .
```

Add the newly built service to your application stack in `docker-compose.yml`
```yml
version: ...
services:
  ...
  say-hello:
    image: say-hello-service
```

Launch the new container in your app
```bash
docker-compose up -d say-hello
```

### Debug your microservice
Requires: 'Develop in a mu.semte.ch stack'.

If desired, [debug](https://rubygems.org/gems/debug) and [Better Errors](https://rubygems.org/gems/better_errors) can be used during development, giving advanced ruby debugging features.

#### Inspecting errors after the fact
Requires: 'Access your microservice directly'.

When an error occurs, an interactive [Better Errors](https://github.com/charliesome/better_errors) error page is available at `http://localhost:8888/__better_errors`.

#### Attach the Chrome debugger
When running in development mode, you can attach the debugger to your microservice and add breakpoints as you're used to. The debugger requires port 9229 to be forwarded, and your service to run in development mode.

```yml
my-ruby-service:
  image: semtech/mu-ruby-template:3.1.0
  ports:
    - 9229:9229
  environment:
    RACK_ENV: "development"
  volumes:
    - /absolute/path/to/your/sources/:/app/
```

Add a breakpoint in your code by inserting a `binding.break` (alias `debugger`, `binding.b`) statement.

After launching your service, open Google Chrome or Chromium and visit [chrome://inspect](chrome://inspect). Once you reach the breakpoint, the file containing your code will be automatically opened in the 'Sources' tab.

### Access your microservice directly
Requires: 'Build a microservice based on mu-ruby-template' or 'Develop in a mu.semte.ch stack'

If you doubt your requests are arriving at your microservice correctly, you can publish it port to access it directly. In the example below, port 8888 is used to access the service directly.

Note this means you will not have the headers set by the identifier and dispatcher.

Update your service definition in `docker-compose.yml` as follows:

```yml
    your-microservice-name:
      ...
      ports:
        - 8888:80
```

Next, recreate the container by executing
```bash
docker-compose up -d your-microservice-name
```

### Add a dependency to your microservice
You can install additional dependencies by including a `Gemfile` file next to your `web.rb`. It works as you would expect: just specify the dependencies in the `Gemfile`. They will be installed automatically at build time. In development mode you will need to restart the container.


### Execute a SPARQL query
The template provides several helpers. One of them, `Mu::query`, allows to easily execute a SPARQL query as shown in the following example:

```ruby
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

### Include utils as globals
The utils can be included as global functions by including the `Mu` module. This makes the code somewhat shorter but may cause conflicts with other libraries in the global namespace.

For example `Mu::query` can then be written as `query`:

```ruby
include Mu

get '/triples' do
  solutions = query("SELECT * WHERE { ?s ?p ?o }")
  ...
end
```

### How to run tests
To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment  with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=test
                -it semtech/mu-ruby-template:3.1.0 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec

## Reference
### Framework
The mu-ruby-template is built on Sinatra. Check [Sinatra's Getting Started guide](https://sinatrarb.com/intro.html) to learn how to build a REST API in Sinatra.

### Utils
The template offers a `Mu` module with utils to facilitate development.

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

#### Mu::update(query)
Executes the given SPARQL update query.

#### Mu::update_modified(subject, modified = DateTime.now)
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

### Debugger
[ruby/debug](https://github.com/ruby/debug) supports multiple frontends for remote debugging of which we advise the Chromium inspector. You can configure the frontend via `RUBY_DEBUG_OPEN_FRONTEND` environment variable. Other options are untested.

### Environment variables
The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT`: SPARQL endpoint URL. Default: `http://database:8890/sparql`
- `MU_SPARQL_TIMEOUT`: timeout (in seconds) for SPARQL queries. Default: 60 seconds.
- `ALLOW_MU_AUTH_SUDO`: Allow sudo queries when the service requests it.
- `DEFAULT_MU_AUTH_SCOPE`: Default mu-auth-scope to use for calls.
- `LOG_LEVEL`: the level of logging (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).
- `USE_LEGACY_UTILS`: when enabled (using `"true"` or `"yes"`) legacy utils from v2 will be included in the root file so they can be used as before (e.g. `query` instead of `Mu::query`). Default: `"true"`
- `PRINT_DEPRECATION_WARNINGS`: Deprecation warnings will be printed for each usage of a legacy util. Default: `"true"`.
- `RACK_ENV`: environment to start the Sinatra application in. Default: `production`. Possible values `production`, `development`, `test`.
- `RUBY_DEBUG_PORT`: port to use for remote debugging. Default: `9229`.
- `RUBY_DEBUG_OPEN_FRONTEND`: frontend to use for debugging. Default: `chrome`. Other options are untested.
- `RUBY_OPTIONS`: options to pass to the ruby command on startup. Default: `--jit`.

### Custom build commands
To execute custom bash statements during the image build (e.g. to install aditional system libraries), provide an `on-build.sh` script in the root of your service. It will be automatically picked up and executed by the Docker build.
