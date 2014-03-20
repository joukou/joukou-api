#!/bin/bash
#
# Author: Isaac Johnston <isaac.johnston@joukou.com>
#
# Configuration and initialization of Basho Riak 2.0-beta1

if [ "$CIRCLECI" ]
then
  rm /etc/riak/app.config
  cp ~/joukou-api/.circle/riak.conf /etc/riak/riak.conf
  cp ~/joukou-api/.circle/env.sh /usr/lib/riak/lib/env.sh
  sudo riak start
  sleep 2
fi

curl -XPUT http://localhost:8098/search/schema/agent -H'content-type:application/xml' --data-binary @dist/agent/schema.xml
curl -XPUT http://localhost:8098/search/index/agent -H'content-type:application/json' -d'{"schema":"agent"}'
sleep 10
sudo riak-admin bucket-type create agent '{"props":{"search_index":"agent","allow_mult":false}}'
sudo riak-admin bucket-type activate agent

curl -XPUT http://localhost:8098/search/schema/persona -H'content-type:application/xml' --data-binary @dist/persona/schema.xml
curl -XPUT http://localhost:8098/search/index/persona -H'content-type:application/json' -d'{"schema":"persona"}'
sleep 10
sudo riak-admin bucket-type create persona '{"props":{"search_index":"persona","allow_mult":false}}'
sudo riak-admin bucket-type activate persona

curl -XPUT http://localhost:8098/search/schema/graph -H'content-type:application/xml' --data-binary @dist/persona/graph/schema.xml
curl -XPUT http://localhost:8098/search/index/graph -H'content-type:application/json' -d'{"schema":"graph"}'
sleep 10
sudo riak-admin bucket-type create graph '{"props":{"search_index":"graph","allow_mult":false}}'
sudo riak-admin bucket-type activate graph

sleep 2