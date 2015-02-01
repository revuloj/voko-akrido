#!/bin/sh

# base=<absolute-path-to-source>
plsrc=revo_radikoj.pl
goal=revo_radikaro
#PL=/usr/bin/env swipl
PL=/usr/local/bin/swipl

exec $PL -q -f "$plsrc" -g "$goal,halt" -t 'halt(1)' --
