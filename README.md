# Freedbin Refresher 🍔

[![Build status][jenkins-badge]][jenkins-build]

Refresher is a service meant to be run in combination with [Feedbin](https://github.com/feedbin/feedbin).

Refresher consists of a single Sidekiq job that :
* Fetches and parses RSS feeds
* Checks for the existence of duplicates against a redis database
* Add new feed entries to redis to be imported back into Feedbin


## Requirements

* Docker
* docker-compose

## Installation

* `wget https://github.com/thomasilliet/freedbin/blob/master/docker-compose.yml`
  * Set config values in the `docker-compose.yml` file
  * `SECRET_KEY_BASE` - Rails Secret Key which needs to be set for security reasons
* `docker-compose up`
* Access the app from `localhost:9292` (first request can take a little while)

All the minimum necessary config parameters required for it to run are set in the Dockerfile. All the config parameters required for interconnectivity with the db etc, are specified in the docker compose file.

The container images are hosted on dockerhub:
* [Feedbin](https://hub.docker.com/r/thomasilliet/feedbin/)
* [Feedbin Refresher](https://hub.docker.com/r/thomasilliet/feedbin-refresher/)

## Release management

I build daily images of feedbin, you have 4 type of release

* **Latest** : Every day
* **Weekly** : Every sunday
* **Monthly** : Every month

And on the latest build, i added latest git head in docker tag :)

## Contributing

Feel free to file PRs for features or fixes you think are specifically useful to the self-hosted version, but if it's generally applicable then contribute to the original Feedbin project which will be merged into this fork periodically.

[jenkins-badge]: https://ci.netboot.fr/job/thomas-illiet/job/feedbin-refresher-docker/job/master/badge/icon
[jenkins-build]: https://ci.netboot.fr/blue/organizations/jenkins/thomas-illiet%2Ffeedbin-refresher-docker/activity?branch=master
