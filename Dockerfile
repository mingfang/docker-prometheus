FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc
RUN apt-get install -y build-essential

#MySql
RUN apt-get install -y mysql-server mysql-client

#Prometheus
RUN mkdir -p /prometheus && \
    cd /prometheus && \
    wget -O - https://github.com/prometheus/prometheus/releases/download/0.15.1/prometheus-0.15.1.linux-amd64.tar.gz | tar zxv

#Required for PromDash
ENV RAILS_ENV production
RUN apt-get install -y libssl-dev libmysqlclient-dev
#RUN gem install bundler

#PromDash
RUN git clone https://github.com/prometheus/promdash.git
RUN cd /promdash && \
    git checkout fix-path-prefix && \
    cp config/database.yml.example config/database.yml && \
    make build

#Confd
RUN wget -O /usr/local/bin/confd  https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 && \
    chmod +x /usr/local/bin/confd

ENV PROMDASH_PATH_PREFIX /promdash
ENV PROMDASH_MYSQL_HOST localhost
ENV PROMDASH_MYSQL_DATABASE promdash
ENV PROMDASH_MYSQL_USERNAME root
#ENV PROMDASH_MYSQL_PASSWORD
ADD mysql.ddl /mysql.ddl
ADD preparedb.sh /preparedb.sh
RUN ./preparedb.sh

ADD etc/confd /etc/confd
ADD prometheus.yml /prometheus/prometheus.yml

#Add runit services
ADD sv /etc/service 

