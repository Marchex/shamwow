FROM ubuntu:16.04
MAINTAINER Tools Team <tools-team@marchex.com>
RUN apt-get update && \

    apt-get install -y build-essential && \
    apt-get install -y libpq-dev postgresql-server-dev-9.5 && \
    apt-get install -y ruby && \
    apt-get install -y ruby-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ["lib", "/root/shamwow/lib/"]
COPY ["bin", "/root/shamwow/bin/"]
COPY ["Gemfile", "/root/shamwow/Gemfile"]
COPY ["shamwow.gemspec", "/root/shamwow/shamwow.gemspec"]

RUN cd /root/shamwow && gem install bundler && bundle install
ENV USER shamwow
ENV CONNECTIONSTRING postgres://postgres@192.168.99.100:54320/shamwow

# CMD cd /root/shamwow && bin/console --knife
CMD bash