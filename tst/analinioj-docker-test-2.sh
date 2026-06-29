#!/bin/bash

target="${1}"

case $target in
docker)

  docker_image="voko-akrido:swipl"
  #requests=1

  # lanĉi la test-procezujon
  docker kill akrido-test
  sleep 2
  docker run --cap-add=SYS_PTRACE -p 8081 --name akrido-test --rm -d ${docker_image}

  # atendi, ĝis ĝi ricevis retpordon
  while ! docker port akrido-test
  do
    echo "$(date) - atendante retpordon"
    sleep 1
  done  
  ;;

gdb)
  sbin/docker-gdb  
  ;;
test)  
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

  echo ""; echo "Petante multfoje analizon per analinioj..."

  URL="http://$HPORT/analinioj"
  SURL="http://$HPORT/statistiko"
  MURL="http://$HPORT/mutex_statistiko"

  JSON='{
  "92": "      nur divenebla, sentebla, analizebla):",
  "94": "        la pentrado […] figuras ne nur la surfacon, sed ankaŭ la enhavon kaj",
  "95": "        esencon de la aferoj",
  "102": "        li estis verisma verkisto, kun humuro kaj, sub tre trankvila surfaco, kun",
  "103": "        bolanta sensemo,",
  "110": "        en Japanio, kun ĝia almenaŭ surface pli stabila sistemo enlanda, regis pli",
  "111": "        favoraj antaŭkondiĉoj por disvolviĝo de la Movado",
  "118": "        ne malofte vortoj en iu latinida lingvo sub la surfaco montras nenion alian ol",
  "119": "        kunfandiĝon de elementoj, kiuj estas pli klare analizeblaj en die ĝermanaj kaj",
  "120": "        slavaj lingvoj",
  "133": "      Dudimensia",
  "134": "      geometria figuro:",
  "136": "         ebena surfaco (inkluzivata de ebeno);",
  "139": "        neebena surfaco;",
  "142": "        kalkulo de la surfaco (areo)",
  "143": "        de la triangulo",
  "151": "      Malnovaj ekvivalentoj:",
  "152": "      areaĵo,",
  "153": "      supraĵo",
  "156": "      Specifaj ebenaj surfacoj:",
  "moduso": "kontrolendaj"
}'

#JSON='{
#    "118": "        ne malofte vortoj en iu latinida lingvo sub la surfaco montras nenion alian ol",
#    "120": "        slavaj lingvoj",
#    "moduso": "kontrolendaj"
#  }'  

  for i in {1..100}
  do
    (
      # -s: ne montru progreson
      # -o /dev/null: ignoru la respondon
      # -w "%{http_code}": eligu nur la http-kodon (e.g., 200, 503)
      #HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL" \
      #    -H "Content-Type: application/json" \
      #    -d "$JSON")
      HTTP=$(curl -s -w "%{http_code}" -X POST "$URL" \
          -H "Content-Type: application/json" \
          -d "$JSON")
      
      echo "#$i: HTTP $HTTP"
      echo "#$i: $(curl -s ${SURL})"
    ) &
  done

  wait

  echo "$(curl -s ${MURL})"

  echo "preta"
  ;;
esac  
