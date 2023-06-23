#!/bin/sh
cd /usr/src/app 2> /dev/null

SKIP_PROMETHEUS_EXPORTER=1 bundle exec bin/rails db:prepare
bundle exec pumactl -F config/puma.rb start
