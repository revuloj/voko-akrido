#!/bin/bash

# Per rsync sinkronigu la rezultojn kun la servilo kie ili montriĝas
#
# Ni bezonas la servilon: AKRIDO_HOST
# kaj sekretan SSH-ŝlosilon: AKRIDO_KEY
#
# Krome vi donu la literojn, kiujn ni sinkronigu kiel argumento $1
# ekz.: 
#    async.sh [a-d]
#
# Tio necesas, ĉar ni ankaŭ forigos dosierojn en la servilo, se ili
# tie ĉi malaperis, sed ne kreis ĉiujn do forigus aliokaze tutajn
# dosierujojn en la cela servilo!

target_dir=/var/www/html/revokontrolo

if [ -z "${AKRIDO_HOST}" ] || [ -z "${AKRIDO_KEY}" ]; then
    echo "Mankas unu el AKRIDO_HOST aŭ AKRIDO_KEY."
    echo "Do ni ne kopias rezultajn dosierojn al la servilo."
    exit 1
fi

# transdonu la ŝlosilo al la agento
eval `ssh-agent -s`
ssh-add - <<< ${AKRIDO_KEY}

#rsync -v -r -c -z --delete --stats ...
# -v = verbose, -r = subdosierujoj, -z = komprimite, -c = nur kies kontrolsumoj diferencas
# -n montru, kio okazus, sed ne efektive sinkronigu!
rsync -v -r -c -z --stats html/$1 revo@${AKRIDO_HOST}:${target_dir}
rsync -v    -c -z --stats html/$1_trovoj.html html/stilo.css html/klarigoj.html revo@${AKRIDO_HOST}:${target_dir}



