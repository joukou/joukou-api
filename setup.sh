#!/bin/bash
#
# Author: Isaac Johnston <isaac.johnston@joukou.com>
# Copyright: (c) 2009-2014 Joukou Ltd. All rights reserved.
#
# Temporary Basho Riak 2.0 setup script. To be replaced by CoffeeScript version
# when ready.

curl -XPUT http://localhost:8098/search/schema/agent -H'content-type:application/xml' --data-binary @dist/agent/schema.xml
curl -XPUT http://localhost:8098/search/index/agent -H'content-type:application/json' -d'{"schema":"agent"}'
sudo riak-admin bucket-type create agent '{"props":{"search_index":"agent","allow_mult":false}}'
sudo riak-admin bucket-type activate agent

curl -XPUT http://localhost:8098/search/schema/persona -H'content-type:application/xml' --data-binary @dist/persona/schema.xml
curl -XPUT http://localhost:8098/search/index/persona -H'content-type:application/json' -d'{"schema":"persona"}'
sudo riak-admin bucket-type create persona '{"props":{"search_index":"persona","allow_mult":false}}'
sudo riak-admin bucket-type activate persona