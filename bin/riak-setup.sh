#!/bin/bash
#
# Author: Isaac Johnston <isaac.johnston@joukou.com>
# Copyright: (c) 2009-2014 Joukou Ltd. All rights reserved.
#
# Configuration and initialization of Basho Riak 2.0-beta1

curl -XPUT http://localhost:8098/search/schema/agent -H'content-type:application/xml' --data-binary @dist/agent/schema.xml
curl -XPUT http://localhost:8098/search/index/agent -H'content-type:application/json' -d'{"schema":"agent"}'
sleep 10
riak-admin bucket-type create agent '{"props":{"search_index":"agent","allow_mult":false}}'
riak-admin bucket-type activate agent

curl -XPUT http://localhost:8098/search/schema/persona -H'content-type:application/xml' --data-binary @dist/persona/schema.xml
curl -XPUT http://localhost:8098/search/index/persona -H'content-type:application/json' -d'{"schema":"persona"}'
sleep 10
riak-admin bucket-type create persona '{"props":{"search_index":"persona","allow_mult":false}}'
riak-admin bucket-type activate persona

curl -XPUT http://localhost:8098/search/schema/graph -H'content-type:application/xml' --data-binary @dist/persona/graph/schema.xml
curl -XPUT http://localhost:8098/search/index/graph -H'content-type:application/json' -d'{"schema":"graph"}'
sleep 10
riak-admin bucket-type create graph '{"props":{"search_index":"graph","allow_mult":false}}'
riak-admin bucket-type activate graph

curl -XPUT http://localhost:8098/search/schema/circle -H'content-type:application/xml' --data-binary @dist/circle/schema.xml
curl -XPUT http://localhost:8098/search/index/circle -H'content-type:application/json' -d'{"schema":"circle"}'
sleep 10
riak-admin bucket-type create circle '{"props":{"search_index":"circle","allow_mult":false}}'
riak-admin bucket-type activate circle


curl -XPUT http://localhost:8098/search/schema/graph_state -H'content-type:application/xml' --data-binary @dist/agent/graph/state/schema.xml
curl -XPUT http://localhost:8098/search/index/graph_state -H'content-type:application/json' -d'{"schema":"graph_state"}'
sleep 10
riak-admin bucket-type create graph_state '{"props":{"search_index":"graph_state","allow_mult":false}}'
riak-admin bucket-type activate graph_state

sleep 2
