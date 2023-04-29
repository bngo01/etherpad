FROM node:lts

ENV ETHERPAD_VERSION 1.8.18

ENV NODE_ENV development

ARG ETHERPAD_PLUGINS="ep_adminpads2 ep_headings2 ep_ldapauth_ng"

WORKDIR /opt/

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl unzip mariadb-client supervisor gzip git python libssl-dev pkg-config build-essential && \
    rm -r /var/lib/apt/lists/*

#RUN curl -SL \
#    https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
#    > etherpad.zip && unzip etherpad && rm etherpad.zip && \
#    mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite

RUN curl -SL \
    https://github.com/bngo01/etherpad-lite/archive/refs/heads/master.zip \
    > etherpad.zip && unzip etherpad && rm etherpad.zip && \
    mv etherpad-lite-master etherpad-lite

WORKDIR etherpad-lite

# install plugins
RUN { [ -z "${ETHERPAD_PLUGINS}" ] || \
      npm install --no-save --legacy-peer-deps ${ETHERPAD_PLUGINS}; }
    #src/bin/installDeps.sh
    #rm -rf ~/.npm

RUN src/bin/installDeps.sh \
    && rm -rf ~/.npm \
    && rm settings.json
COPY entrypoint.sh /entrypoint.sh

RUN sed -i 's/^node/exec\ node/' bin/run.sh

VOLUME /opt/etherpad-lite/var
RUN ln -s var/settings.json settings.json
ADD supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
