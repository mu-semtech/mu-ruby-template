#!/bin/bash
cd /usr/src/app
if [ "$RACK_ENV" == "production" ];
then
    exec bundle exec ruby $JRUBY_OPTIONS --server web.rb
else
    bundle install
    if [ "$RACK_ENV" == "test" ];
    then
        bundle exec rspec
    else
        exec bundle exec ruby $JRUBY_OPTIONS --dev web.rb
    fi
fi
