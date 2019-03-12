#!/bin/bash

bundle exec middleman build

supervisord -n -c supervisord.conf
# umjesto supervisord za development
# bundle exec middleman server --watcher-force-polling
