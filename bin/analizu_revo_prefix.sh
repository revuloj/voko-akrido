#!/bin/bash

# uzu argumenton ab  por analizi la artikolojn txt/ab*.txt
# kaj '' por analizi ĉiujn artikolojn

# base=<absolute-path-to-source>
plsrc=revo_kontrolo.pl
goal="analizu_revo_art_prefix($1)"
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl
PERL=/usr/bin/perl

cd pro
$PL -q -f "$plsrc" -g "$goal" -t halt --

cd ..
source bin/elfiltru_trovojn.sh # -k html/ 
#elfiltru_trovojn.sh # -k html/ 

