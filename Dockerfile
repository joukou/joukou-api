FROM joukou/nodejs:staging
MAINTAINER Isaac Johnston isaac.johnston@joukou.com

ENV DEBIAN_FRONTEND noninteractive
ENV JOUKOU_API_PORT 2101
ENV JOUKOU_API_HOST 0.0.0.0

ADD src /var/node/src
ADD coffeelint.json /var/node/
ADD gulpfile.coffee /var/node/
ADD gulpfile.js /var/node/
ADD package.json /var/node/
WORKDIR /var/node
RUN npm install
RUN ./node_modules/.bin/gulp build

EXPOSE 2101