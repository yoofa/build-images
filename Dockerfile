FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Set up TEMP directory
ENV TEMP=/tmp
RUN chmod a+rwx /tmp

# Install Linux packages
ADD tools/install-deps.sh /tmp/
RUN bash /tmp/install-deps.sh
ADD  tools/install-depot_tools.sh /tmp/
RUN bash /tmp/install-depot_tools.sh

ENV PATH=/setup/depot_tools:$PATH

RUN rm -rf /var/lib/apt/lists/*
