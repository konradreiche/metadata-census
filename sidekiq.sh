#!/bin/sh
redis-cli -c "FLUSHALL"
bundle exec sidekiq -C config/sidekiq.yml
