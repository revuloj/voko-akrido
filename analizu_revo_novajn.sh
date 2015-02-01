#!/bin/sh

# base=<absolute-path-to-source>
plsrc=analizu_revo_xml.pl
goal=analizu_revo_art_novaj
#PL=/usr/bin/env swipl
PL=/usr/local/bin/swipl

exec $PL -q -f "$plsrc" -g "$goal,halt" -t 'halt(1)' --
