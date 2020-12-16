plsrc=revoxml_elshuto.pl
goal=xml_download
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl

echo "elŝutante XML arĥivon de retavortaro.de ..."
cd pro
$PL -q -f "$plsrc" -g "$goal" -t halt --
cd ..

zip=`/bin/ls -Art tmp/*.zip | /usr/bin/tail -n 1`
echo "zip: "$zip

echo "aktualigante XML-dosierojn el $zip ..."
unzip -juq ${zip} -d xml/ "revo/xml/*.xml"



