FROM erikap/ruby-sinatra:ruby-2.1-latest

MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>

ADD . /usr/src/app

ONBUILD ADD . /app/
ONBUILD RUN ln -s /app /usr/src/app/ext \
     && cd /usr/src/app \
     && bundle install --without development test
