FROM erikap/ruby-sinatra:ruby-2.1-latest

MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>

ENV APP_ENTRYPOINT web.rb
ENV LOG_LEVEL info
ENV MU_SPARQL_ENDPOINT 'http://database:8890/sparql'

ADD . /usr/src/app

ONBUILD ADD . /app/
ONBUILD RUN ln -s /app /usr/src/app/ext \
     && cd /usr/src/app \
     && bundle install --without development test
