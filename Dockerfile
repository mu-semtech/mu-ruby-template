FROM ruby:3.1

LABEL maintainer="erika.pauwels@gmail.com"

ENV APP_ENTRYPOINT web.rb
ENV RUBY_OPTS '--jit'
ENV RACK_ENV production
ENV LOG_LEVEL info
ENV RUBY_DEBUG_PORT 12345
ENV RUBY_DEBUG_HOST 0.0.0.0
ENV RUBY_DEBUG_OPEN_FRONTEND rdbg
ENV MU_SPARQL_ENDPOINT 'http://database:8890/sparql'
ENV MU_APPLICATION_GRAPH 'http://mu.semte.ch/application'
ENV TRUSTED_IP 0.0.0.0/0

EXPOSE 80

RUN mkdir -p /usr/src/app
ADD . /usr/src/app

WORKDIR /app

RUN ln -s /app /usr/src/app/ext \
     && ln -s /app/spec /usr/src/app/spec/ext \
     && mkdir /logs \
     && touch /logs/application.log \
     && ln -sf /dev/stdout /logs/application.log \
     && cd /usr/src/app \
     && bundle install

ONBUILD ADD . /app/
ONBUILD RUN if [ -f /app/on-build.sh ]; \
     then \
        echo "Running custom on-build.sh of child" \
        && chmod +x /app/on-build.sh \
        && /bin/bash /app/on-build.sh ;\
     fi
ONBUILD RUN cd /usr/src/app \
     && bundle install

CMD ["/bin/bash", "/usr/src/app/mu-ruby-template.sh"]
