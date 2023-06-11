#syntax=docker/dockerfile:1

FROM debian:11

COPY . /app
RUN apt-get update \
    && apt-get install -y gcc make cmake flex bison g++ \
    && apt-get install -y curl \
    && curl http://snapshot.debian.org/archive/debian-security/20220210T090326Z/pool/updates/main/o/openjdk-8/openjdk-8-jre-headless_8u322-b06-1~deb9u1_amd64.deb -o openjdk-8-jre-headless.deb \
    # dependencies of openjdk-8-jre-headless.deb
    && apt-get install -y java-common libcups2 liblcms2-2 libnss3 libpcsclite1 libxi6 libxrender1 libxtst6 \
    && apt-get -f install -y \
    && apt-get install -y ./openjdk-8-jre-headless.deb \
    # Clean up the apt cache, see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run.
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD [ "/bin/sh" ]
