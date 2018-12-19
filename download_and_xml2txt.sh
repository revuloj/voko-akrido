#zip=$1

plsrc=revoxml_elshuto.pl
goal=xml_download
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl

lynx="/usr/bin/lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin"
xsltproc=/usr/bin/xsltproc
XSL=xsl/revotxt_eo.xsl
time=`date +%Y%m%d_%H%M%S`
#recent_zip="/bin/ls -Art tmp/*.zip | /usr/bin/tail -n 1"

echo "elŝutante XML arĥivon de retavortaro.de ..."
cd pro
$PL -q -f "$plsrc" -g "$goal" -t halt --
cd ..

zip=`/bin/ls -Art tmp/*.zip | /usr/bin/tail -n 1`
echo "zip: "$zip

echo "aktualigante XML-dosierojn el $zip ..."
unzip -juq ${zip} -d xml/ "revo/xml/*.xml"

echo "tradukante ĉiujn pli novajn dosierojn el XML al TXT ..."
for src in xml/*.xml; do
    
    # konstruu nomon de la txt-dosiero
    suffix=${src#xml/}
    file=${suffix%%.xml}
    trg=txt/${file}.txt

    if [ "$src" -nt "$trg" ]; then
        printf '%s\n' "$src -> $trg"
        # echo "$xsltproc $XSL $src 2>> tmp/${time}_x2t.log | $lynx > $trg"
        $xsltproc $XSL $src 2>> tmp/${time}_x2t.log | $lynx > $trg
    fi

done


