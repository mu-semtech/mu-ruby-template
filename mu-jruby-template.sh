#!/bin/bash
cd /usr/src/app
if [ "$RACK_ENV" == "production" ];
then
    exec bundle exec ruby $JRUBY_OPTIONS $APP_ENTRYPOINT
else
    bundle install
    if [ "$RACK_ENV" == "test" ];
    then
        bundle exec rspec
    else
        exec bundle exec rerun --dir /app --background -- ruby $JRUBY_OPTIONS --dev $APP_ENTRYPOINT
    fi
fi
