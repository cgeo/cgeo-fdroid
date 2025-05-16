FROM registry.gitlab.com/fdroid/docker-executable-fdroidserver:master

RUN apt-get update \
 && apt-get install -y \
      jq \
      python3-pip \
      wget \
 && ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 && ln -s /home/vagrant/fdroidserver/fdroid /usr/local/bin

# Workaround bug:
# https://gitlab.com/fdroid/docker-executable-fdroidserver/-/issues/28#note_2308549848
RUN git clone --recursive https://github.com/androguard/androguard.git && \
    cd androguard && \
    git reset --hard v4.1.2 && \
    pip install . --break-system-packages

ADD https://ci.cgeo.org/jnlpJars/slave.jar /apk/slave.jar
COPY files/ /
ENV PATH="${PATH}:/opt/android-sdk/build-tools/32.0.0"
ENTRYPOINT ["sh", "-c", ". /etc/profile.d/bsenv.sh && $@", "-s"]
# CMD ["/usr/local/bin/run.sh"]
