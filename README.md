# Mu Sinatra template
Template for running Sinatra microservices

## Using the template
Extend the `semtech/mu-sinatra-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

The template provides a `log` object to the user for logging. Just do `log.info "Hello world"`. The log level can be set through the `LOG_LEVEL` environment variable (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).

## Example Dockerfile

    FROM semtech/mu-sinatra-template:ruby-2.1-latest
    MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>
    # ONBUILD of mu-sinatra-template takes care of everything


## Configuration
The triple store used in the backend is linked to the login service container as `database`.

The `MU_APPLICATION_GRAPH` environment variable specifies the graph in the triple store the microservice will work in.

## Helper methods
The template provides the user with several helper methods.
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
