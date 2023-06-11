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
    && apt-get install -y vim git gcc make cmake \
    && apt-get install -y g++ openjdk-11-jre \
    && apt-get install -y flex bison clang-format clang-tidy valgrind lcov \
    # Clean up the apt cache, see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run.
    && rm -rf /var/lib/apt/lists/*
# Give sudo privilege to user.
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
