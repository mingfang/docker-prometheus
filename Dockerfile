FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute

#Confd
RUN wget -O /usr/local/bin/confd  https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 && \
    chmod +x /usr/local/bin/confd

#Prometheus
RUN wget -O - https://github.com/prometheus/prometheus/releases/download/v1.2.1/prometheus-1.2.1.linux-amd64.tar.gz | tar zxv
RUN mv prometheus* prometheus

#BlackBox Exporter
RUN wget -O - https://github.com/prometheus/blackbox_exporter/releases/download/v0.2.0/blackbox_exporter-0.2.0.linux-amd64.tar.gz | tar zx
RUN mv blackbox_exporter* blackbox_exporter

#Alertmanager
RUN wget -O - https://github.com/prometheus/alertmanager/releases/download/v0.5.0-beta.0/alertmanager-0.5.0-beta.0.linux-amd64.tar.gz | tar zx
RUN mv alertmanager* alertmanager

COPY prometheus.yml /etc/prometheus/
COPY alert.rules /etc/prometheus/rules/
COPY alertmanager.yml /etc/alertmanager/
COPY etc/confd /etc/confd

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
