#!/bin/bash

#swipl -s pro/analizo-servo.pl -g 'daemon' -t 'halt(1)' -- --port 8081 #-t 'halt(1)'&

HPORT='localhost:8081'

URL="http://$HPORT/analinioj"
SURL="http://$HPORT/statistiko"

# https://superuser.com/questions/272265/getting-curl-to-output-http-status-code
while ! curl -I "http://$HPORT/" 2> /dev/null
do
  echo "$(date) - atendante malfermon de TTT-servo"
  sleep 3
done

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


for i in {1..100}
do
  (
    # -s: ne montru progreson
    # -o /dev/null: ignoru la respondon
    # -w "%{http_code}": eligu nur la http-kodon (e.g., 200, 503)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL" \
        -H "Content-Type: application/json" \
        -d "$JSON")
    
    echo "#$i: HTTP $HTTP_CODE"
    echo "#$i: $(curl -s ${SURL})"
  ) &
done

wait

echo "preta"
