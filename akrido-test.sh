#!/bin/bash

echo ">TESTO: analizo?teksto=ĉevalidoj+henas+iihiii"
curl http://localhost:8081/analizo?teksto=pra%C4%89evalidoj+henas+iihiii

echo
echo ">TESTO: analinioj kun Json"
curl -X POST -H "Content-Type: application/json" \
  -d '{"1": "praĉevalidoj", "5": "henas iihiii"}' http://localhost:8081/analinioj

echo
echo ">TESTO: analinioj kun Json kaj moduso: kontrolendaj"
curl -X POST -H "Content-Type: application/json" \
  -d '{"1": "praĉevalidoj", "5": "henas iihiii", "moduso": "kontrolendaj"}' \
  http://localhost:8081/analinioj
  
echo
