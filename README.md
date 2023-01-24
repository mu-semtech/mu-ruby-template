# Mu Ruby template
Template for running Ruby/[Sinatra](http://www.sinatrarb.com/) microservices

## Tutorials
### Building your first microservice with Sinatra
![](http://mu.semte.ch/wp-content/uploads/2017/04/ruby_sinatra-e1492071925754-1024x839.jpg)

The microservices are one of the core components of the mu.semte.ch architecture. Each microservice has its own responsibility, providing a tiny part of the application’s functionality while running in a Docker container. But how can you build such a microservice? To which rules does the microservice need to comply to run on the mu.semte.ch platform? The answer is simple: use the mu.semte.ch templates!

A template is an easy starting point to build your own microservice. Its core purpose is to facilitate the development of a microservice that can run on the mu.semte.ch platform. There are templates available in several programming languages. As the name implies, this is a template to build microservices in Ruby.

#### Sinatra takes the stage

The mu-ruby-template is based on the lightweight Ruby web framework [Sinatra](http://www.sinatrarb.com/). So in essence, everything you can do in Sinatra, you can also do in the template. We will start with the implementation of a simple ‘Hello World’ API endpoint.

Open a new file ‘web.rb’ and add the following lines of code:
```rb
get '/hello' do
    status 200
    { message: 'Hello world! }.to\_json
end
```

We’ve now defined a simple API endpoint on the path ‘/hello’. Next, we will wrap these lines of code in the mu-ruby-template.

Create a Dockerfile next to the web.rb file with the following content:
```Dockerfile
    FROM semtech/mu-ruby-template:2.4.0-ruby2.3
```
That’s it! You’ve build your first Ruby microservice in mu.semte.ch. If you now build this Docker image and include it in your mu-project, you will have a /hello endpoint available in your platform. Don’t forget to add a rule to your dispatcher to make this endpoint available to the frontend application.

#### Developing the microservice

Building the Docker image each time you’ve changed some code is rather cumbersome during development. The template therefore supports development with live-reload. Start a container based on the mu-ruby-template image and mount your code in the /app folder:
```bash
    > docker run --volume /path/to/your/code:/app
                 -e RACK_ENV=development
                 -d semtech/mu-ruby-template:2.4.0-ruby2.3
```
Each time you change some code, the microservice will be automatically updated.

#### What’s more?

By this time, you might be wondering what the benefit of the template is as Sinatra is already an easy-to-use platform on its own. The mu-ruby-template offers more than just the Sinatra framework. A lot of boilerplate code that you will probably need, is already provided. For example, we don’t want a developer to write the code how to query to a SPARQL endpoint over and over again for each microservice. Therefore the template provides helper methods to make it as easy as possible for a developer to build a microservice.

You want to execute a SPARQL query? Just add in your web.rb:
```rb
query 'SELECT \* WHERE { ?s ?p ?o }'
```
You want to insert data in the triple store? Just add in your web.rb:
```rb
update "INSERT DATA {
    GRAPH <#{graph}> { 
        <http://example.com/mails/58B187FA6AA88E0009000001> <#{MU\_CORE.uuid}\> \\"58B187FA6AA88E0009000001\\"
    }
}"
```
You want to generate a random UUID? Just add in your web.rb:
```rb
generate\_uuid()
```
We can continue with examples like these for a while. But it may be a better idea for you to have a look at the overview of all helpers in the [below](#helper-methods).

The helpers are automatically available in your Sinatra application (web.rb). However, if you want to use the helpers outside of the Sinatra context, just include the module with the helpers in your file by adding:
```rb
    require_relative '/usr/src/app/sinatra_template/utils.rb'
    include SinatraTemplate::Utils
```

#### Using additional libraries

The mu-ruby-template contains several libraries like the [linkeddata gem](https://rubygems.org/gems/linkeddata) for everything related to RDF/SPARQL, [pry](https://rubygems.org/gems/pry) and [better_errors](https://rubygems.org/gems/better_errors) for debugging and [rspec](https://rubygems.org/gems/rspec) for testing. If you need additional gems for your microservice, just create a Gemfile next to your web.rb and list the required gems as you normally do. You don’t have to repeat the gems that are already included in the template. The required gems will be automatically installed at build time. While developing in a container as described above, you will have to restart the container for the new included gems to be installed.

#### Examples
There are already [some microservices available](https://github.com/search?q=topic%3Amu-service+org%3Amu-semtech&type=Repositories) that use the mu-ruby-template. Have a look at them to see how simple it is to build a microservice based on this template. The [login-](https://github.com/mu-semtech/login-service) and [registration-service](https://github.com/mu-semtech/registration-service) make extensive use of the available helpers methods. The [mu-migrations-service](https://github.com/mu-semtech/mu-migrations-service) on the other hand shows how to use the helpers outside the Sinatra context.

*This tutorial has been adapted from Erika Pauwels's mu.semte.ch article. You can view it [here](https://mu.semte.ch/2017/04/13/building-your-first-microservice-with-sinatra/)*


### Building an RDFa importer service
![](http://mu.semte.ch/wp-content/uploads/2017/07/IMG_6145-1024x768.png)

RDFa is a way to embed a Semantic Model into Linked Data.  In this tutorial we describe how we can implement a microservice to import these contents into the mu.semte.ch stack.  We will go through our own development process and see what we discovered.

#### Getting started

We create a new folder with the basic stub for a new Ruby template.

```rb
# /path/to/importer/web.rb
get '/' do
 content_type 'application/json'
 { data: { attributes: { hello: 'world' } } }.to_json
end
```

```Dockerfile
# /path/to/importer/Dockerfile
FROM semtech/mu-ruby-template:2.4.0-ruby2.3
MAINTAINER Aad Versteden <madnificent@gmail.com>
# see https://github.com/mu-semtech/mu-ruby-template for more info
```

With these files in place we can wire this new service up in a standard mu-project by updating our `docker-compose.yml` and `dispatcher.ex`.

In the `docker-compose.yml` we add our development component and link it to the dispatcher.
```yaml
dispatcher:
  ...
  links:
    - rdfaimporter:rdfaimporter
...
rdfaimporter:
  image: semtech/mu-ruby-template:2.4.0-ruby2.3
  links:
    - db:database
  ports:
    - "8888:80"
  environment:
    RACK_ENV: "development"
  volumes:
   - "/path/to/importer/:/app"
```

In the dispatcher, we add the following above *`match _ do`*

```ex
# new content in dispatcher.ex
match "/import/*path" do
  Proxy.forward conn, path, "http://rdfaimporter/"
end
```

After starting our project, we can surf to http://localhost/importer and we will receive our default hello world output.  As we update the code in our ruby-template, we will see the updates appear live.

#### Importing RDFa

*Hint: If you’re working your way through this tutorial, you won’t need to execute the steps in this section.*

During our search for a good solution, we search online for a good RDFa importing library.  We find the [rdf-rdfa](https://github.com/ruby-rdf/rdf-rdfa) library on GitHub.  This library looks clean so we create a new Gemfile and add the latest version to it.

```gemfile
# /path/to/importer/Gemfile
gem 'rdf-rdfa', '2.2.2'
```

When we restart the container, which we need to do because we changed the dependencies, we notice that the mu-ruby-template we see the following output.
```bash
rdfaimporter_1 | You have requested:
rdfaimporter_1 | rdf-rdfa = 2.2.2
rdfaimporter_1 | 
rdfaimporter_1 | The bundle currently has rdf-rdfa locked at 2.1.0.
rdfaimporter_1 | Try running `bundle update rdf-rdfa`
```

Turns out the `mu-ruby-template` already made the decision for us.  We can remove our Gemfile and continue humming away with the version offered by the mu-ruby-template.

#### Parsing the RDFa file
With the RDFa library selected, and documentation in place, we work through a first version for parsing the file.

We save an RDFa annotated file (without blank nodes) into *`./data/share/our-example.html`*, where the import service can find it.
```html
<div resource="http://test.com/Articles/81216194" vocab="http://test.com/vocabulary/" typeof="Article" class="article">
  <h2 property="hasTitle">New article</h2>
  <p property="hasContent">
    Content of an which refers to <span property="referredPerson" typeof="foaf:Agent" resource="mailto:madnificent@gmail.com"><a property="email-address" href="mailto:madnificent@gmail.com">Aad Versteden</a></span>.
  </p>
</div>
```
We will use this example in a simple case with debugging output.  We can see the contents in an easy-to-interpret format by pasting it at http://rdfa.info/play.  In our first try we send this file through the rdf-rdfa library and we dump the contents.

For a cleaner interface, we change our get to process on *`/import/`* and update the dispatcher accordingly:
```ex
 # updated content in dispatcher.ex
 match "/import/*path" do
   Proxy.forward conn, path, "http://rdfaimporter/import/"
 end
```

Then we implement a basic dump of the parsed contents:
```ex
require 'rdf/rdfa'

get '/import/' do
  content_type 'application/json'

  graph = RDF::Graph.load("/share/#{params[:file]}")
  dump = graph.dump :ttl

  { data: { attributes: { parsed: dump } } }.to_json
end
```

When we access http://localhost:8888/import/?file=our-example.html, we see the resulting turtle in the response.  Yay, we’re ready to write this into the triplestore.

#### Writing contents

We can write contents to the triplestore by using *`sparql_client.insert_data_graph`*.  At first, we try this with a temporary graph.
require 'rdf/rdfa'
```ex
require 'rdf/rdfa'

get '/import/' do
  content_type 'application/json'

  graph = RDF::Graph.load("/share/#{params[:file]}")
  dump = graph.dump :ttl

  sparql_client.insert_data graph, :graph => "http://test.com/1"

  { data: { attributes: { parsed: dump } } }.to_json
end
```

When we surf to http://localhost:8888/import/?file=our-example.html, our data is inserted into the triplestore.  We find it by going to  http://localhost:8890 and executing a query which lists all triples of the specified graph.

```sparql
SELECT * WHERE {
  GRAPH <http://test.com/1> {
    ?s ?p ?o.
  }
}
```

Our contents are inserted into the application graph by updating the graph statement.
```ex
require 'rdf/rdfa'

get '/import/' do
 content_type 'application/json'

 graph = RDF::Graph.load("/share/#{params[:file]}")
 dump = graph.dump :ttl

 sparql_client.insert_data graph, :graph => ENV['MU_APPLICATION_GRAPH']

 { data: { attributes: { parsed: dump } } }.to_json
end
```

#### Conclusion
With this, mu.semte.ch has been extended to import RDFa documents.  There is the slight limitation that only documents without blank nodes are allowed.  An extension to the twelve-line-long microservice could help here.

Down the line it might be worth exploring connecting with a file upload, making the importer safer, and more solid.

*This tutorial has been adapted from Aad Versteden's mu.semte.ch article. You can view it [here](https://mu.semte.ch/2017/07/06/building-an-rdfa-importer-service/)*

## How-To
### Quickstart
Extend the `semtech/mu-ruby-template` and set a maintainer. That's it.

Configure your entrypoint through the environment variable `APP_ENTRYPOINT` (default: `web.rb`). You can use the Gemfile as you would expect.

#### Example Dockerfile
```Dockerfile
    FROM semtech/mu-ruby-template:2.12.0
    LABEL maintainer="erika.pauwels@gmail.com"
    # ONBUILD of mu-ruby-template takes care of everything
```


### Developing with the template
Livereload is enabled automatically when running in development mode.  You can embed the template easily in a running mu.semte.ch stack by launching it in the `docker-compose.yml` with the correct links.  If desired, pry and Better Errors can be used during development, giving advanced ruby debugging features.

#### Live reload
When developing, you can use the template image, mount the volume with your sources in `/app` and add a link to the database. Set the `RACK_ENV` environment variable to `development`. The service will live-reload on changes. You'll need to restart the container when you define additional dependencies in your `Gemfile`.

    docker run --link virtuoso:database \
           -v `pwd`:/app \
           -p 8888:80 \
           -e RACK_ENV=development \
           --name my-js-test \
           semtech/mu-ruby-template:2.12.0

#### Develop in mu.semte.ch stack
When developing inside an existing mu.semte.ch stack, it is easiest to set the development mode and mount the sources directly.  This makes it easy to setup links to the database and the dispatcher.

Optionally, you can publish the microservice on a different port, so you can access it directly without the dispatcher.  In the example below, port 8888 is used to access the service directly.  We set the path to our sources directly, ensuring we can develop the microservice in its original place.

```yaml
    yourMicroserviceName:
      image: semtech/mu-ruby-template:2.12.0
      ports:
        - 8888:80
      environment:
        RACK_ENV: "development"
      links:
        - db:database
      volumes:
        - /absolute/path/to/your/sources/:/app/
```

#### Debugging with pry and Better Errors
Add a breakpoint in your code by inserting a `binding.pry` statement. 

When an error occurs, an interactive [Better Errors](https://github.com/charliesome/better_errors) error page is available at `http://{container-ip}/__better_errors`. It's important to access the error page via the container's IP directly and not through localhost, identifier, dispatcher, etc.


### Using helpers outside the Sinatra context
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


### Writing tests for your microservice
To test your app, run the container with `RACK_ENV` set to `test`. All [rspec](http://rspec.info/) tests matching `*_spec.rb` in `spec/` and its subdirectories will be executed.

    docker run --rm -e RACK_ENV=test microservice-image

To run the tests while developing, start an interactive container in the test enviroment  with your code folder mounted in `/app`:

    docker run --volume /path/to/your/code:/app
                -e RACK_ENV=test
                -it semtech/mu-ruby-template:2.12.0 /bin/bash

You can now run your tests inside the container with:

    bundle install
    rspec

### Custom build commands
To execute custom bash statements during the image build (e.g. to install aditional system libraries), provide an `on-build.sh` script in the root of your service. It will be automatically picked up and executed by the Docker build.


## Reference
### Versions
The following versions of the mu-ruby-template are available:
* `2.12.0`
* `2.11.1`; `2.11.1-ruby2.5`
* `2.10.0`; `2.10.0-ruby2.5`
* `2.9.0` ; `2.9.0-ruby2.5`
* `2.8.0` ; `2.8.0-ruby2.5`
* `2.7.0` ; `2.7.0-ruby2.5`
* `2.6.0` ; `2.6.0-ruby2.3`
* `1.3.1-ruby2.1`

### Configuration

The template supports the following environment variables:

- `MU_SPARQL_ENDPOINT`: SPARQL read endpoint URL. Default: `http://database:8890/sparql` (the triple store should be linked as `database` to the microservice).

- `MU_APPLICATION_GRAPH`: configuration of the graph in the triple store the microservice will work in. Default: `http://mu.semte.ch/application`. The graph name can be used in the service via the `graph` helper method.

- `MU_SPARQL_TIMEOUT`: timeout (in seconds) for SPARQL queries. Default: 60 seconds.

- `LOG_LEVEL`: the level of logging (default: `info`, values: `debug`, `info`, `warn`, `error`, `fatal`).



### Helper methods
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


### Experimental features
#### MU_SPARQL_UPDATE_ENDPOINT environment variable
Configure the SPARQL update endpoint path. This should be a path relative to the base of `MU_SPARQL_ENDPOINT`. Default: `/sparql`. The update endpoint can be retrieved via the `update_endpoint` helper method.
