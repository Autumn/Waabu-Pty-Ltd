#!/bin/bash
source ~/.rvm/scripts/rvm
ruby /home/site/store/store.rb 2>>/var/log/store_access.log &
