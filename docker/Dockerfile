FROM jenkins/jenkins:lts

# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves && \
    /usr/local/bin/install-plugins.sh email-ext && \
    /usr/local/bin/install-plugins.sh mailer && \
    /usr/local/bin/install-plugins.sh slack && \
    /usr/local/bin/install-plugins.sh htmlpublisher && \
    /usr/local/bin/install-plugins.sh greenballs && \
    /usr/local/bin/install-plugins.sh simple-theme-plugin && \
    /usr/local/bin/install-plugins.sh kubernetes && \
    /usr/local/bin/install-plugins.sh azure-ad && \
    /usr/local/bin/install-plugins.sh groovy && \
    /usr/local/bin/install-plugins.sh configuration-as-code

USER root
#RUN echo "root:Password1234!" | chpasswd
#RUN apt-get update -y; exit 0
#RUN apt-get install tcpdump -y
#RUN apt-get install vim -y

RUN mkdir /var/jenkins_config
RUN chown jenkins:jenkins /var/jenkins_config

USER jenkins
COPY ./ssl/cert.pem /var/lib/jenkins/cert.pem
COPY ./ssl/key_rsa.pem /var/lib/jenkins/key_rsa.pem

COPY ./jenkins.yaml /var/jenkins_config/jenkins.yaml
