# Mu Ruby template
Template for running Ruby/[Sinatra](http://www.sinatrarb.com/) microservices

## Using the template
Extend the `semtech/mu-ruby-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

## Example Dockerfile

    FROM semtech/mu-ruby-template:2.4.0-ruby2.3
    MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>
    # ONBUILD of mu-ruby-template takes care of everything

## Configuration

The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT`: SPARQL read endpoint URL. Default: `http://database:8890/sparql` (the triple store should be linked as `database` to the microservice).

- `MU_APPLICATION_GRAPH`: configuration of the graph in the triple store the microservice will work in. Default: `http://mu.semte.ch/application`. The graph name can be used in the service via the `graph` helper method.

- `MU_SPARQL_TIMEOUT`: timeout (in seconds) for SPARQL queries. Default: 60 seconds.

## Develop a microservice using the template
To use the template while developing your app, start a container in development mode with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=development
	        -d semtech/mu-ruby-template:2.4.0-ruby2.3

Changes will be automatically picked up by Sinatra.

To get the [Better Errors](https://github.com/charliesome/better_errors) working, you need to access your microservice directly instead of going through the identifier and dispatcher. You can retrieve your microservice's IP address by running the command: `docker inspect {container-name} | grep -i ip`.

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
                -it semtech/mu-ruby-template:2.4.0-ruby2.3 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec -c

## Experimental features
#### MU_SPARQL_UPDATE_ENDPOINT environment variable
Configure the SPARQL update endpoint path. This should be a path relative to the base of `MU_SPARQL_ENDPOINT`. Default: `/sparql`. The update endpoint can be retrieved via the `update_endpoint` helper method.

#### sparql_escape()
The Ruby templates extends the core classes `String`, `Date`, `Integer`, `Float` and `Boolean` with a `sparql_escape` method. This method can be used to avoid SPARQL injection by escaping user input while constructing a SPARQL query. E.g.

```
query =  " INSERT DATA {"
query += "   GRAPH <#{settings.graph}> {"
query += "     <#{user_uri}> a <#{RDF::Vocab::FOAF.Person}> ;"
query += "                   <#{RDF::Vocab::FOAF.name}> #{name.sparql_escape} ;"
query += "                   <#{RDF::Vocab::DC.created}> #{now.sparql_escape} ."
query += "   }"
query += " }"      
```
