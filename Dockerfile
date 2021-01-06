FROM newtmitch/sonar-scanner:4.5

RUN npm config set unsafe-perm true && \
  npm install --silent --save-dev -g typescript@3.5.2 && \
  npm config set unsafe-perm false && \
  apk add --no-cache ca-certificates jq

ENV NODE_PATH "/usr/lib/node_modules/"

COPY entrypoint.sh /entrypoint.sh
COPY break_build.sh /break_build.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /break_build.sh

ENTRYPOINT ["/entrypoint.sh"]