#syntax=docker/dockerfile:1

FROM debian:11

USER root
ARG USERNAME=nonroot
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
COPY .. /home/$USERNAME/st-lang
RUN apt-get update \
    && apt-get install -y dumb-init sudo \
    && apt-get install -y vim git gcc make cmake \
    && apt-get install -y flex bison clang-format clang-tidy valgrind \
    # Clean up the apt cache, see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run.
    && rm -rf /var/lib/apt/lists/*
# Give sudo privilege to user.
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
# Make user the owner of its directory.
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/

USER $USERNAME
WORKDIR /home/$USERNAME/st-lang

# dumb-init acts as PID 1 and immediately spawns the command as a child process,
# taking care to properly handle and forward signals as they are received.
# See https://github.com/Yelp/dumb-init#dumb-init.
ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD [ "/bin/bash" ]
