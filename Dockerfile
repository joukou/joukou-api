FROM joukou/nodejs
MAINTAINER Isaac Johnston isaac.johnston@joukou.com

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

EXPOSE 2101
