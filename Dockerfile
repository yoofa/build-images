FROM ubuntu:22.04

RUN groupadd --gid 1000 builduser \
  && useradd --uid 1000 --gid builduser --shell /bin/bash --create-home builduser

# Set up TEMP directory
ENV TEMP=/tmp
RUN chmod a+rwx /tmp

# Install Linux packages
ADD tools/install-deps.sh /tmp/
RUN bash /tmp/install-deps.sh

USER builduser

ADD  tools/install-depot_tools.sh /tmp/
RUN bash /tmp/install-depot_tools.sh

WORKDIR /home/builduser
