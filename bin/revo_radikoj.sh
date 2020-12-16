#!/bin/sh

# base=<absolute-path-to-source>
plsrc=pro/revo_radikoj.pl
goal=revo_radikaro
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl

#cd pro
$PL -q -f "$plsrc" -g "$goal" -t halt --
#cd ..

