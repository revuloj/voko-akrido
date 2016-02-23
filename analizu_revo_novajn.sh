#!/bin/sh

# base=<absolute-path-to-source>
plsrc=analizu_revo_art.pl
goal=analizu_revo_art_novaj
#PL=/usr/bin/env swipl
PL=/usr/local/bin/swipl
PERL=/usr/bin/perl

# exec 
$PL -q -f "$plsrc" -g "$goal,halt" -t 'halt(1)' --

$PERL elfiltru_trovojn.perl -k kontrolitaj/ 

