FROM node:10-alpine
RUN apk add --no-cache 'su-exec>=0.2' bash
ENV NODE_ENV production
ENV GHOST_CLI_VERSION 1.10.0
RUN npm config set unsafe-perm true
RUN npm install -g "ghost-cli@$GHOST_CLI_VERSION"
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_VERSION 2.22.1
ENV DOMAIN localhost
WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
COPY setup.sh /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/setup.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["setup.sh", "docker-entrypoint.sh"]
CMD ["node", "current/index.js"]