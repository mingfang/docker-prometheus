FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#Confd
RUN wget -O /usr/local/bin/confd  https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 && \
    chmod +x /usr/local/bin/confd

#Prometheus
RUN wget -O - https://github.com/prometheus/prometheus/releases/download/v1.8.0/prometheus-1.8.0.linux-amd64.tar.gz | tar zxv
RUN mv prometheus* prometheus

#BlackBox Exporter
RUN wget -O - https://github.com/prometheus/blackbox_exporter/releases/download/v0.8.1/blackbox_exporter-0.8.1.linux-amd64.tar.gz | tar zx
RUN mv blackbox_exporter* blackbox_exporter

#Alertmanager
RUN wget -O - https://github.com/prometheus/alertmanager/releases/download/v0.8.0/alertmanager-0.8.0.linux-amd64.tar.gz | tar zx
RUN mv alertmanager* alertmanager

#StatsD
RUN wget -O - https://github.com/prometheus/statsd_exporter/releases/download/v0.4.0/statsd_exporter-0.4.0.linux-amd64.tar.gz | tar zx
RUN mv statsd_exporter* statsd_exporter

COPY prometheus.yml /etc/prometheus/
COPY alert.rules /etc/prometheus/rules/
COPY alertmanager.yml /etc/alertmanager/
COPY etc/confd /etc/confd
COPY test.sh /

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
