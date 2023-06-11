#syntax=docker/dockerfile:1

FROM debian:11

USER root
ARG USERNAME=st-lang
# Non-root user for security purposes.
#
# UIDs below 10,000 are a security risk, as a container breakout could result
# in the container being ran as a more privileged user on the host kernel with
# the same UID.
#
# Static GID/UID is also useful for chown'ing files outside the container where
# such a user does not exist.
# See https://github.com/hexops/dockerfile#use-a-static-uid-and-gid.
RUN addgroup --gid 10001 --system $USERNAME \
    && adduser --uid 10000 --system --ingroup $USERNAME --home /home/$USERNAME $USERNAME
RUN apt-get update \
    && apt-get install -y sudo \
    && apt-get install -y vim git gcc make cmake g++ \
    && apt-get install -y flex bison clang-format clang-tidy valgrind lcov \
    && apt-get install -y curl \
    && curl http://snapshot.debian.org/archive/debian-security/20220210T090326Z/pool/updates/main/o/openjdk-8/openjdk-8-jre-headless_8u322-b06-1~deb9u1_amd64.deb -o openjdk-8-jre-headless.deb \
    # dependencies of openjdk-8-jre-headless.deb
    && apt-get install -y java-common libcups2 liblcms2-2 libnss3 libpcsclite1 libxi6 libxrender1 libxtst6 \
    && apt-get -f install -y \
    && apt-get install -y ./openjdk-8-jre-headless.deb \
    # Clean up the apt cache, see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run.
    && rm -rf /var/lib/apt/lists/*
# Give sudo privilege to user.
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
