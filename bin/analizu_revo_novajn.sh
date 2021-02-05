#!/bin/bash

# base=<absolute-path-to-source>
plsrc=revo_kontrolo.pl
goal=analizu_revo_art_novaj
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl
PERL=/usr/bin/perl

# exec 
cd pro
$PL -q -f "$plsrc" -g "$goal,halt" -t 'halt(1)' --

cd ..
source bin/elfiltru_trovojn.sh # -k html/ 

