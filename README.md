# Mu Sinatra template
Template for running Sinatra microservices

## Using the template
Extend the `semtech/mu-sinatra-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

## Example Dockerfile

    FROM semtech/mu-sinatra-template:1.2.0-ruby2.1 
    MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>
    # ONBUILD of mu-sinatra-template takes care of everything

## Configuration
The SPARQL endpoint can be configured through the `MU_SPARQL_ENDPOINT` environment variable. By default this is set to `http://database:8890/sparql`. In that case the triple store used in the backend should be linked to the login service container as `database`.

The `MU_APPLICATION_GRAPH` environment variable specifies the graph in the triple store the microservice will work in. By default this is set to `http://mu.semte.ch/application`. The graph name can be used in the service via `settings.graph`.

## Develop a microservice using the template
To use the template while developing your app, start a container in development mode with your code folder mounted in `/usr/src/app/ext`:

    docker run --volume /path/to/your/code:/usr/src/app/ext
                -e RACK_ENV=development
	        -d semtech/mu-sinatra-template:1.2.0-ruby2.1 
    
Changes will be automatically picked up by Sinatra.

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
Executes the given SPARQL select query.

#### update(query)
Executes the given SPARQL update query.

#### update_modified(subject, modified = DateTime.now.xmlschema)
Executes a SPARQL query to update the modification date of the given subject URI (string). The date defaults to now.


## Writing tests for your microservice
To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment with your code and `spec/` folder mounted:

    docker run --volume /path/to/your/code:/usr/src/app/ext
                --volume /path/to/your/code/spec:/usr/src/app/spec/ext
                -e RACK_ENV=test
                -it semtech/mu-sinatra-template:1.2.0-ruby2.1 /bin/bash
    
You can now run your tests inside the container with:

    bundle install
    rspec -c


To get help on the available options of `rspec` execute:

    rspec -h
