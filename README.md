# Mu Ruby template
Template for running Ruby/[Sinatra](http://www.sinatrarb.com/) microservices

## Using the template
Extend the `semtech/mu-ruby-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

## Example Dockerfile

    FROM semtech/mu-ruby-template:2.0.0-ruby2.3
    MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>
    # ONBUILD of mu-ruby-template takes care of everything

## Configuration

The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT` is used to configure the SPARQL endpoint.

  - By default this is set to `http://database:8890/sparql`. In that case the triple store used in the backend should be linked to the microservice container as `database`.


- `MU_APPLICATION_GRAPH` specifies the graph in the triple store the microservice will work in.

  - By default this is set to `http://mu.semte.ch/application`. The graph name can be used in the service via `settings.graph`.


- `MU_SPARQL_TIMEOUT` is used to configure the timeout for SPARQL queries.

## Develop a microservice using the template
To use the template while developing your app, start a container in development mode with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=development
	        -d semtech/mu-ruby-template:2.0.0-ruby2.3

Changes will be automatically picked up by Sinatra.

To get the [Better Errors](https://github.com/charliesome/better_errors) working, you need to access your microservice directly instead of going through the identifier and dispatcher. You can retrieve your microservice's IP address by running the command: `docker inspect {container-name} | grep -i ip`.

## Helper methods
The template provides the user with several helper methods.

#### log
The template provides a `log` object to the user for logging. Just do `log.info "Hello world"`. The log level can be set through the `LOG_LEVEL` environment variable (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).

Logs are written to the `/logs` directory in the docker container.

#### generate_uuid()
Generate a random UUID (String).

#### session_id_header(request)
Get the session id from the request headers.

#### rewrite_url_header(request)
Get the rewrite URL from the request headers.

#### validate_json_api_content_type(request)
Validate whether the Content-Type header contains the JSONAPI Content-Type. Returns a `400` otherwise.

#### validate_resource_type(expected_type, data)
Validate whether the type specified in the JSON data is equal to the expected type. Returns a `409` otherwise.

#### error(title, status = 400)
Returns a JSONAPI compliant error response with the given status code (default: `400`).

#### query(query)
Executes the given SPARQL select/ask/construct query.

#### update(query)
Executes the given SPARQL update query.

#### update_modified(subject, modified = DateTime.now)
Executes a SPARQL query to update the modification date of the given subject URI (string). The date defaults to now.


## Writing tests for your microservice
To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment  with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=test
                -it semtech/mu-ruby-template:1.2.0-ruby2.1 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec -c

## Experimental features
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
