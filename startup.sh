#!/bin/bash
if [ "$RACK_ENV" == "production" ];
then
    bundle install --without development test
    bundle exec ruby --server $MAIN_APP_FILE -p 80
else
    bundle install
    if [ "$RACK_ENV" == "test" ];
    then
        bundle exec rspec
    else
        bundle exec ruby --dev $MAIN_APP_FILE -p 80 -o '0.0.0.0'
    fi
fi
