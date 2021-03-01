FROM quay.io/thoth-station/s2i-minimal-notebook:latest

ARG JAVA_VERSION=1.8.0
ENV ENABLE_MICROPIPENV="1"
USER root

# Install java

RUN yum -y install java-$JAVA_VERSION-openjdk maven &&\
    yum clean all

RUN cd /tmp
RUN wget https://oss.sonatype.org/service/local/repositories/releases/content/org/teiid/teiid/10.2.1/teiid-10.2.1-jdbc.jar

ENV JAVA_HOME=/usr/lib/jvm/jre

# Copying in override assemble/run scripts
COPY .s2i/bin /tmp/scripts
RUN mv /opt/app-root/builder/run /opt/app-root/builder/run.base
COPY .s2i/bin/run /opt/app-root/builder/
# Copying in source code
COPY . /tmp/src
# Change file ownership to the assemble user. Builder image must support chown command.
RUN chown -R 1001:0 /tmp/scripts /tmp/src
USER 1001
RUN /tmp/scripts/assemble
CMD /tmp/scripts/run
