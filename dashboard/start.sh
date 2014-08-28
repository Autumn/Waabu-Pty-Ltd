#!/bin/bash
source ~/.rvm/scripts/rvm
ruby /home/site/dashboard/server.rb 1>>/var/log/dashboard_access.log 2>>/var/log/dashboard_access.log &
