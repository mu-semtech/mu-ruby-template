# Mu Ruby template
Template for running Ruby/[Sinatra](http://www.sinatrarb.com/) microservices

## Using the template
Extend the `semtech/mu-ruby-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

### Example Dockerfile

    FROM semtech/mu-ruby-template:2.7.0
    LABEL maintainer="erika.pauwels@gmail.com"
    # ONBUILD of mu-ruby-template takes care of everything

### Versions
The following versions of the mu-ruby-template are available:
* 2.7.0 ; 2.7.0-ruby2.5
* 2.6.0 ; 2.6.0-ruby2.3
* 1.3.1-ruby2.1

## Configuration

The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT`: SPARQL read endpoint URL. Default: `http://database:8890/sparql` (the triple store should be linked as `database` to the microservice).

- `MU_APPLICATION_GRAPH`: configuration of the graph in the triple store the microservice will work in. Default: `http://mu.semte.ch/application`. The graph name can be used in the service via the `graph` helper method.

- `MU_SPARQL_TIMEOUT`: timeout (in seconds) for SPARQL queries. Default: 60 seconds.

- `LOG_LEVEL`: the level of logging (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).

## Developing with the template
Livereload is enabled automatically when running in development mode.  You can embed the template easily in a running mu.semte.ch stack by launching it in the `docker-compose.yml` with the correct links.  If desired, pry and Better Errors can be used during development, giving advanced ruby debugging features.

### Live reload
When developing, you can use the template image, mount the volume with your sources in `/app` and add a link to the database. Set the `RACK_ENV` environment variable to `development`. The service will live-reload on changes. You'll need to restart the container when you define additional dependencies in your `Gemfile`.

    docker run --link virtuoso:database \
           -v `pwd`:/app \
           -p 8888:80 \
           -e RACK_ENV=development \
           --name my-js-test \
           semtech/mu-ruby-template:2.7.0

### Develop in mu.semte.ch stack
When developing inside an existing mu.semte.ch stack, it is easiest to set the development mode and mount the sources directly.  This makes it easy to setup links to the database and the dispatcher.

Optionally, you can publish the microservice on a different port, so you can access it directly without the dispatcher.  In the example below, port 8888 is used to access the service directly.  We set the path to our sources directly, ensuring we can develop the microservice in its original place.

    yourMicroserviceName:
      image: semtech/mu-ruby-template:2.7.0
      ports:
        - 8888:80
      environment:
        RACK_ENV: "development"
      links:
        - db:database
      volumes:
        - /absolute/path/to/your/sources/:/app/


### Debugging with pry and Better Errors
Add a breakpoint in your code by inserting a `binding.pry` statement. 

When an error occurs, an interactive [Better Errors](https://github.com/charliesome/better_errors) error page is available at `http://{container-ip}/__better_errors`. It's important to access the error page via the container's IP directly and not through localhost, identifier, dispatcher, etc.

## Helper methods
The template provides the user with several helper methods in Sinatra. Some helpers cannot be used outside the Sinatra context.

#### error(title, status = 400)
Returns a JSONAPI compliant error response with the given status code (default: `400`).

#### graph
Returns the application graph configured through the `MU_APPLICATION_GRAPH`.

#### generate_uuid()
Generate a random UUID (String).

#### @json_body
The parsed JSON body of the request.

#### log
The template provides a [Logger](https://ruby-doc.org/stdlib-2.3.0/libdoc/logger/rdoc/Logger.html) `log` object to the user for logging. Just do `log.info "Hello world"`. The log level can be set through the `LOG_LEVEL` environment variable (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).

Logs are written to the `/logs` directory and `STDOUT` in the docker container.

#### query(query)
Executes the given SPARQL select/ask/construct query.

#### rewrite_url_header(request)
Get the rewrite URL from the request headers.

#### session_id_header(request)
Get the session id from the request headers.

#### sparql_client
Returns a SPARQL::Client instance connection to the SPARQL endpoint configured through the `MU_SPARQL_ENDPOINT` environment variable.

#### sparql_escape ; sparql_escape_{string|uri|date|datetime|bool|int|float}(value)
The Ruby templates extends the core classes `String`, `Date`, `DateTime`, `Time`, `Integer`, `Float`, `Boolean` and `URI` with a `sparql_escape` method. This method can be used to avoid SPARQL injection by escaping user input while constructing a SPARQL query. E.g.

```
query =  " INSERT DATA {"
query += "   GRAPH <#{settings.graph}> {"
query += "     <#{user_uri}> a <#{RDF::Vocab::FOAF.Person}> ;"
query += "                   <#{RDF::Vocab::FOAF.name}> #{name.sparql_escape} ;"
query += "                   <#{RDF::Vocab::DC.created}> #{now.sparql_escape} ."
query += "   }"
query += " }"
```

Next to the extensions, the template also provides a helper function per datatype that takes any value as parameter. E.g. `sparql_escape_uri("http://mu.semte.ch/application")`.

#### update(query)
Executes the given SPARQL update query.

#### update_modified(subject, modified = DateTime.now)
Executes a SPARQL query to update the modification date of the given subject URI (string). The date defaults to now.

#### validate_json_api_content_type(request)
Validate whether the Content-Type header contains the JSONAPI Content-Type. Returns a `400` otherwise.

#### validate_resource_type(expected_type, data)
Validate whether the type specified in the JSON data is equal to the expected type. Returns a `409` otherwise.


## Helpers outside the Sinatra context
The template provides several helpers that are automatically included in the Sinatra application (`web.rb`), but some of them can also be used outside the Sinatra context. Just include the `SinatraTemplate::Utils` module in your file. 

```
require_relative '/usr/src/app/sinatra_template/utils.rb'
include SinatraTemplate::Utils
```

The following [helper methods](https://github.com/mu-semtech/mu-ruby-template#helper-methods) are provided:
* graph
* generate_uuid
* log
* query(query)
* sparql_client
* update(query)
* update_modified(subject, modified = DateTime.now)


## Writing tests for your microservice
To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment  with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=test
                -it semtech/mu-ruby-template:2.7.0 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec -c

## Custom build commands
To execute custom bash statements during the image build (e.g. to install aditional system libraries), provide an `on-build.sh` script in the root of your service. It will be automatically picked up and executed by the Docker build.

## Experimental features
#### MU_SPARQL_UPDATE_ENDPOINT environment variable
Configure the SPARQL update endpoint path. This should be a path relative to the base of `MU_SPARQL_ENDPOINT`. Default: `/sparql`. The update endpoint can be retrieved via the `update_endpoint` helper method.
