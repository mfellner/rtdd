# Read The Docs Docker [![Docker Pulls](https://img.shields.io/docker/pulls/mfellner/rtdd.svg)](https://registry.hub.docker.com/u/mfellner/rtdd)

Dockerized variant of [Read The Docs](https://github.com/rtfd/readthedocs.org).

## Usage

    docker run \
      -p 8000:8000 \
      -e DJANGO_USER=root \
      -e DJANGO_PASS=pass \
      mfellner/rtfd

Provide a custom Django administrator username and password!
