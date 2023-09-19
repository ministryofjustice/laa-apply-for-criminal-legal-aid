#!/bin/sh
cd /usr/src/app 2> /dev/null

# Start clamav virus database update and then scanner in background
# https://docs.clamav.net/manual/Usage/Scanning.html
freshclam -d &
echo -e "updating clamav virus signature database..."
until [[ -e ${MAIN_FILE} ]]

# Note starting clamd in foreground as per documentation, daemonizes itself...
echo -e "starting clamd..."
clamd

bundle exec bin/rails db:prepare
bundle exec pumactl -F config/puma.rb start
