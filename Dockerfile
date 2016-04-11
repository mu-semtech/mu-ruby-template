FROM erikap/ruby-sinatra:ruby-2.1-latest

MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>

ENV APP_ENTRYPOINT web.rb
ENV LOG_LEVEL info
ENV MU_SPARQL_ENDPOINT 'http://database:8890/sparql'
ENV MU_APPLICATION_GRAPH 'http://mu.semte.ch/application'

ADD . /usr/src/app

RUN ln -s /app /usr/src/app/ext \
     && ln -s /app/spec /usr/src/app/spec/ext \
     && cd /usr/src/app \
     && bundle install

ONBUILD ADD . /app/
ONBUILD RUN cd /usr/src/app \
     && bundle install
