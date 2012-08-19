#!/bin/bash
kill -9 $(ps -ef | awk '/[r]uby stubs.rb/{ print $2 }')
ruby stubs.rb profiles/kilkari.profile &> /var/log/kilkari/stubs.log &
echo "Logs can be found @ /var/log/kilkari/stubs.log"
