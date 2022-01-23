#!/bin/bash

# tuj finu se unuopa komando fiaskas 
# - necesas por distingi sukcesan de malsukcesa testaro
set -e

docker_image="${1:-voko-akrido:latest}"

# lanĉi la test-procezujon
docker run -p 8081 --name akrido-test --rm -d ${docker_image}

# atendi, ĝis ĝi ricevis retpordon
while ! docker port akrido-test
do
  echo "$(date) - atendante retpordon"
  sleep 1
done

DPORT=$(docker port akrido-test | head -n 1)
HPORT=${DPORT/#*-> }

echo "retpordo:" $HPORT
echo "Lanĉo de la servo daŭras iomete pro enlegado de la gramatiko kaj vortaro..."

# https://superuser.com/questions/272265/getting-curl-to-output-http-status-code
while ! curl -I "http://$HPORT/" 2> /dev/null
do
  echo "$(date) - atendante malfermon de TTT-servo"
  sleep 3
done

# momente ni nur testas, ĉu la retpetoj estas sukcesaj. Uzante 'jq' ks
# ni povus ankaŭ pli detale rigardi ĉu la enhavo estas kiel atendita...

echo ""; echo "Petante indeks-paĝon..."
curl -fsI "http://$HPORT/akrido/"

echo ""; echo "Kontrolante JSON (2 linioj kun 2 eraroj)..."
curl -fs -X POST "http://$HPORT/analinioj" \
   -H 'Content-Type: application/json' \
   -d '{"1":"tiu ĉi linio enhvas unu eraron.","5":"tiu ĉi ankŭ unu eraron!","moduso":"kontrolendaj"}'

echo ""; echo ""; echo "Analizo kun eligo TEXT (1 linio)..."
curl -fs -X POST "http://$HPORT/analizo" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -d "numero=12&formato=text&teksto=Ju+laboro+pli+publica,+des+pli+granda+la+krtiko" 

echo ""; echo ""; echo "Analizo kun eligo HTML (1 linio)..."
curl -fs -X POST "http://$HPORT/analizo" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -d "numero=12&formato=html&teksto=teksto+kun+eraaaro" 


echo ""; echo "Forigi..."
docker kill akrido-test