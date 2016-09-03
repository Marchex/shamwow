FROM ubuntu:16.04
MAINTAINER Jimmy Carter <jcarter@marchex.com>
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
COPY ["id_rsa", "/root/.ssh/id_rsa"]

RUN cd /root/shamwow && gem install bundler && bundle install

CMD cd /root/shamwow && bin/console --user jcarter --dns --knife