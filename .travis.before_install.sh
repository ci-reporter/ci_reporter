#!/bin/bash

env

set -x

rvm use 1.9.3 --install --binary --fuzzy
rvm 1.9.3 do gem install racc
RACC=$(rvm 1.9.3 do gem open -c echo racc | tail -1)
echo $RACC | sed 's,ruby-1.9.3[^/]*,jruby'
