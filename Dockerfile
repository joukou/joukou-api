# Copyright (c) 2014 Joukou Ltd. All rights reserved.
FROM joukou/nodejs-service
MAINTAINER Isaac Johnston <isaac.johnston@joukou.com>

ENV DEBIAN_FRONTEND noninteractive
ENV JOUKOU_API_PORT 2101
ENV JOUKOU_API_HOST 0.0.0.0

ADD src /var/nodejs/src
ADD coffeelint.json /var/nodejs/
ADD gulpfile.coffee /var/nodejs/
ADD gulpfile.js /var/nodejs/
ADD package.json /var/nodejs/
WORKDIR /var/nodejs
RUN npm install
RUN ./node_modules/.bin/gulp build
RUN chown -R nodejs:nodejs /var/nodejs

VOLUME [ "/sys/fs/cgroup" ]

# Expose ports
#   2101 intra-cluster Staging HTTP
#   2201 intra-cluster Production HTTP
EXPOSE 2101 2201

# Execute systemd by default
CMD [ "/bin/systemd-init" ]
