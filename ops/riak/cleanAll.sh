#!/bin/bash
./ops/riak/clean.coffee --type=agent --bucket=agent
./ops/riak/clean.coffee --type=persona --bucket=persona
./ops/riak/clean.coffee --type=circle --bucket=circle
./ops/riak/clean.coffee --type=graph --bucket=graph