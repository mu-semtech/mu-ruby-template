# Mu Sinatra template
Template for running Sinatra microservices

## Using the template
Put your entrypoint in `web.rb`. You can use the Gemfile as you would expect.

Extend the `semtech/mu-sinatra-template` and set a maintainer. That's it.

## Example Dockerfile

    FROM semtech/mu-sinatra-template:ruby-2.1-latest
    MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>
    # ONBUILD of mu-sinatra-template takes care of everything


## Configuration
        
The triple store used in the backend is linked to the login service container as `database`.

The `MU_APPLICATION_GRAPH` environment variable specifies the graph in the triple store the microservice will work in.

