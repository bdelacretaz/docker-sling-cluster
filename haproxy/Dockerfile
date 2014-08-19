FROM dockerfile/haproxy
MAINTAINER bdelacretaz@apache.org
ADD haproxy /etc/haproxy

# get and setup confd
ADD tmp /tmp
WORKDIR /tmp
RUN tar zxvf confd_0.3.0_linux_amd64.tar.gz 
RUN mv confd /usr/local/bin/confd
ADD confd /etc/confd

# run confd and haproxy
WORKDIR /
ADD root /
RUN chmod +x start.sh
CMD ./start.sh  