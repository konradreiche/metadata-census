# Metadata Census

[![Build Status](https://travis-ci.org/platzhirsch/metadata-census.png)](http://travis-ci.org/platzhirsch/metadata-census)

A platform for monitoring the quality of metadata.

## Getting Started

Metadata Census requires a running MongoDB and Redis server. The web application is started via Rails:

```
$ bundle install
$ rails server
```

Do not forget to start the Sidekiq instance:

```
$ bundle exec sidekiq
```
