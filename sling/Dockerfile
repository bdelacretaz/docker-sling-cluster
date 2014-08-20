FROM centos:centos6
MAINTAINER bdelacretaz@apache.org

RUN yum -y update
RUN yum install -y java-1.7.0-openjdk-devel.x86_64

ADD fsroot /
CMD /bin/bash /start.sh
