#!/bin/bash
cd /usr/src/app
if [ "$RACK_ENV" == "production" ];
then
  exec ruby $RUBY_OPTIONS web.rb
else
  bundle install
  if [ "$RACK_ENV" == "test" ];
  then
    rspec
  else
    exec ruby $RUBY_OPTIONS web.rb
  fi
fi
