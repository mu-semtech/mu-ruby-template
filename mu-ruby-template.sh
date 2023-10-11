#!/bin/bash
cd /usr/src/app
if [ "$RACK_ENV" == "production" ];
then
  exec ruby $RUBY_OPTIONS $APP_ENTRYPOINT
else
  bundle install
  if [ "$RACK_ENV" == "test" ];
  then
    bundle exec rspec
  else
    exec rerun --background -- ruby $RUBY_OPTIONS $APP_ENTRYPOINT
  fi
fi
