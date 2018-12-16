#!/bin/bash

# ĉar tiu skripto estas ankaŭ lanĉata de radiko (root)
# kiel servo, necesas iom da manipulado por eltrovi
# la uzanton (ordinare revo aŭ revo-test)

# eltrovu absolutan padon de tiu ĉi skripto
script=$(readlink -f "$BASH_SOURCE")
base=$(dirname "$script")
#base=/home/revo/voko/swi

# eltrovu en kiu hejmo ni estas
suffix=${base#/home/}
user=${suffix%%/*}

# difinu pliajn variablojn por la http-demono

plsrc=${base}/analizo-servo.pl
goal=analizo_servo:daemon
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl
pidfile=/var/lock/swi.analizilo.${user}
#user=revo
home=/home/${user}
etc=${home}/etc
workers=10
if [ "$user" = "revo-test" ]
  then
      port=9091
      syslog=anali-tst
  else
      port=8081
      syslog=analizilo
fi

cd ${base}
${PL} -q -f "${plsrc}" -g "${goal}" -t "halt" -p agordo=${etc} -- \
    --port=${port} --syslog=${syslog} --pidfile=${pidfile} \
    --user=${user} --group=${user}  --workers=${workers} 



