#!/bin/bash

# tiu skripto estu uzata por docker, ne por la normala Unix-servo

# eltrovu absolutan padon de tiu ĉi skripto
script=$(readlink -f "$BASH_SOURCE")
base=$(dirname "$script")
#base=/home/revo/voko/swi

# eltrovu en kiu hejmo ni estas
#suffix=${base#/home/}
user=revo #${suffix%%/*}

# difinu pliajn variablojn por la http-demono

plsrc=${base}/pro/analizo-servo.pl
port=8081
#goal=analizo_servo:server\(${port}\)
goal=analizo_servo:daemon
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl
#user=revo
home=/home/${user}
etc=${home}/etc
workers=10


cd ${base}/pro
${PL} -f "${plsrc}" -g "${goal}" -t "halt" -p agordo=${etc} --\
    --user=${user} --no-fork --workers=${workers} --port=${port}
    # --group=${user} --user=${user} --port=${port} --syslog=${syslog} --pidfile=${pidfile} \



