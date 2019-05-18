FROM node:8-alpine
RUN apk add --no-cache 'su-exec>=0.2' bash socat
ENV NODE_ENV production
ENV DOMAN localhost
ENV GHOST_INSTALL /tmp/ghost
ENV GHOST_CONTENT /tmp/ghost/content

RUN npm config set unsafe-perm true
RUN npm install -g "ghost-cli@1.9.4"; set -ex; mkdir -m 777 -p "$GHOST_INSTALL"; \
	su-exec node ghost install "2.1.2" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
	cd "$GHOST_INSTALL"; \
	su-exec node ghost config --ip 0.0.0.0 --port $PORT --no-prompt --db sqlite3 --url http://$DOMAN:$PORT --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	su-exec node ghost config paths.contentPath "$GHOST_CONTENT"; \
	su-exec node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
	readlink -f "$GHOST_INSTALL/config.development.json"; mkdir -m 777 -p "$GHOST_CONTENT"; \
  chmod -R 777 "$GHOST_INSTALL"

WORKDIR $GHOST_INSTALL
EXPOSE $PORT
CMD ["node", "current/index.js"]