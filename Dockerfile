FROM newrelic/infrastructure
FROM txt3rob/ruby-2.2.2-docker

# For nodejs
RUN	apt-get -y update
RUN apt-get -y install nodejs vim sudo

# For postgre sql: https://www.postgresql.org/download/linux/ubuntu/
## RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
## RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
## RUN	apt-get -y update
RUN apt-get -y install postgresql postgresql-contrib libpq-dev
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf
## https://stackoverflow.com/questions/2942485/psql-fatal-ident-authentication-failed-for-user-postgres
RUN sed -i 's/127.0.0.1\/32/0.0.0.0\/0/g' /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
RUN sed -i 's/md5/trust/g' /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
RUN sed -i 's/peer/trust/g' /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf

# For newrelic-ruby-kata
ENV USER=postgres
WORKDIR /home
RUN git clone https://github.com/AstinCHOI/newrelic-ruby-kata
WORKDIR /home/newrelic-ruby-kata
RUN bundle install

# For newrelic infra: https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/linux-installation/docker-container-infrastructure-monitoring/#custom-setup
ADD newrelic-infra.yml /etc/newrelic-infra.yml

##
EXPOSE 3000
ENTRYPOINT ["/bin/bash", "-l", "-c", "service postgresql restart && bundle exec rake db:create && pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $USER -d newrelic-ruby-kata_development public/sample-data.dump; bash"]

# rails server --binding=0.0.0.0