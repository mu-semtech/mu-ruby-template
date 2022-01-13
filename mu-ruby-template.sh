#!/bin/bash
cd /usr/src/app
if [ "$RACK_ENV" == "production" ];
then
  ruby $RUBY_OPTS web.rb
else
  bundle install
  if [ "$RACK_ENV" == "test" ];
  then
    rspec
  else
    ruby $RUBY_OPTS web.rb
  fi
fi
