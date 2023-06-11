#syntax=docker/dockerfile:1

FROM debian:11

COPY . /app
RUN apt-get update \
    && apt-get install -y gcc make cmake flex bison g++ openjdk-11-jre \
    # Clean up the apt cache, see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run.
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD [ "/bin/sh" ]
