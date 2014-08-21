FROM centos:centos6
MAINTAINER bdelacretaz@apache.org

RUN yum -y update
RUN yum install -y java-1.7.0-openjdk-devel.x86_64

ADD fsroot /

# Create the Sling state during Docker image build
# (TODO remove Sling id file?)
RUN /bin/bash /start.sh true

# Run Sling from the state created during image build
CMD /bin/bash /start.sh false
