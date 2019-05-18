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
ENV PORT 2368

RUN set -ex; mkdir -p "$GHOST_INSTALL"; chown node:node "$GHOST_INSTALL"; \
	su-exec node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
	cd "$GHOST_INSTALL"; \
	su-exec node ghost config --ip 0.0.0.0 --port $PORT --no-prompt --db sqlite3 --url "http://$DOMAIN:$PORT" --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	su-exec node ghost config paths.contentPath "$GHOST_CONTENT"; \
	su-exec node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
	readlink -f "$GHOST_INSTALL/config.development.json"; \
	mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT"; \
	chown node:node "$GHOST_CONTENT"
RUN set -eux; \
	cd "$GHOST_INSTALL/current"; \
	sqlite3Version="$(npm view . optionalDependencies.sqlite3)"; \
	if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then \
		apk add --no-cache --virtual .build-deps python make gcc g++ libc-dev; \
		su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source; \
		apk del --no-network .build-deps; \
	fi
WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE $PORT
CMD ["node", "current/index.js"]