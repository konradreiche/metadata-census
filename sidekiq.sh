#!/bin/sh
redis-cli -c "flushall"
bundle exec sidekiq -t 0
