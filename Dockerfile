FROM ubuntu:16.04
MAINTAINER Tools Team <REDACTED@REDACTED.com>
RUN apt-get update && \

    apt-get install -y build-essential && \
    apt-get install -y libpq-dev postgresql-server-dev-9.5 && \
    apt-get install -y ruby && \
    apt-get install -y ruby-dev && \
    apt-get install -y openssh-client && \
    rm -rf /var/lib/apt/lists/*

COPY ["lib", "/root/shamwow/lib/"]
COPY ["bin", "/root/shamwow/bin/"]
COPY ["Gemfile", "/root/shamwow/Gemfile"]
COPY ["shamwow.gemspec", "/root/shamwow/shamwow.gemspec"]
RUN cd /root/shamwow && gem install bundler && bundle install
ENV USER shamwow
ENV CONNECTIONSTRING postgres://postgres@localhost:5432/shamwow
COPY ["conf/*.rb", "/root/.chef/"]
COPY ["conf/*.pem", "/root/.chef/"]
# use ssh-keygen to setup permissions on files
RUN ssh-keygen -b 2048 -t rsa -f /root/id_rsa -q -N ""
COPY ["conf/id_rsa", "/root/.ssh/"]

# copy id_rsa
# copy .chef/user.pem
# copy knife_hosted.rb
# copy knife_prem.rb
# copy other shell sugar

# CMD cd /root/shamwow && bin/console --knife
CMD bash