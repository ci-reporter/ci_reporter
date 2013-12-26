#!/bin/bash

set -x

# Link to pre-built racc for JRuby
[ "$TRAVIS_RUBY_VERSION" != "jruby" ] && exit 0
rvm 1.9.3 do gem install racc
GEMDIR=$(rvm 1.9.3 do gem env gemdir)
JRUBY_GEMDIR=$(rvm jruby do gem env gemdir)

rm -f $JRUBY_GEMDIR/{gems,specifications}/racc*
ln -s $GEMDIR/gems/racc-* $JRUBY_GEMDIR/gems/
ln -s $GEMDIR/specifications/racc-* $JRUBY_GEMDIR/specifications/
