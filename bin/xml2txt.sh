#!/bin/bash

#set -x

# Vi povas doni prefikson kiel unua argumento: xml2txt.sh k
# tiam konvertiĝas nur xml/k*.xml, se ili estas pli novaj ol 
# la korespondaj txt/k*.xml
# Se vi volas aktualigi ĉiujn, voku sen argumento.

lynx="/usr/bin/lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin"
xsltproc=/usr/bin/xsltproc
XSL=xsl/revotxt_eo.xsl
time=`date +%Y%m%d_%H%M%S`

# kontrolu ĉu programoj estas instalitaj 
if [[ -z "$(which lynx)" ]]; then
    echo "Mankas lynx!"
    exit 1
fi

if [[ -z "$(which xsltproc)" ]]; then
    echo "Mankas xsltproc"
    exit 1
fi

if [[ ! -f "$XSL" ]]; then
    echo "Mankas XSL-dosiero."
    exit 1
fi

echo "tradukante ĉiujn aktualigitajn dosierojn el XML al TXT ... (daŭras iom...) ${1}*.xml"
for src in xml/${1}*.xml; do
    
    # konstruu nomon de la txt-dosiero
    suffix=${src#xml/}
    file=${suffix%%.xml}
    trg=txt/${file}.txt

    #printf '%s\n' "$src -> $trg ?"

    if [ "$src" -nt "$trg" ]; then
        # printf '%s\n' "$src -> $trg"
        # echo "$xsltproc $XSL $src 2>> tmp/${time}_x2t.log | $lynx > $trg"
        $xsltproc $XSL $src 2>> tmp/${time}_x2t.log | $lynx > $trg
    fi

done


