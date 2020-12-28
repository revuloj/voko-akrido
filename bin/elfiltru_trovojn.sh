#!/bin/bash

# ni rigardas en dosierujojn html/a .. html/z kaj elfiltras la trovojn
# de antaŭ analizo kaj kreas dosierojn html/a_trovoj.html .. html/z_trovoj.html
# Se dosierujo html/x ne ekzistas aŭ estas malplena ni transsaltas ĝin

function elfiltru {
  d=$1
  outformat=$2
  revoart="http://retavortaro.de/revo/art/"

  #suffix=${d#html/}

  if [ $outformat == "html" ]; then
    outfile="${d}_trovoj.html"
    echo "skribante al $outfile"
    cat <<EOH > "$outfile"
    <html>
      <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <link title="stilo" type="text/css" rel="stylesheet" href="stilo.css"></head>
      </head>
      <body>
        <h1>Rezulto el la vortanalizo de Revo-artikoloj</h1>
        <p>
          La sekvajn kontrolindajn vortojn trovis la vortanalizilo en Revo-artikoloj.
          Por prijuĝi ilin <a href="klarigoj.html">vidu ankaŭ la klarigojn</a>.
        </p>
EOH

    echo "elfiltru en $d..."
    # 1. grep: trovi neanlizeblajn/dubindajn/kuntiritajn vortojn
    #    (-o = only matching, -H with filename -E extended regex syntax (, ) etc)
    # 2. sed: forigu prefikson kaj sufikson de la artikola dosiernomo
    # 3. awk: forigu duoblajn vortojn
    # 4. awk: grupigu trovojn laŭ dosiernomo kaj eligu kiel html kun a-referencoj
    grep -oHE '<span class="[^">]*(neanaliz|dubebla|kuntirita)[^<]*"[^"]+</span>' "$d"/* \
      | sed 's/.*html\/.\///' | sed 's/\.html//' | \
      awk '!a[$0]++' - | \
      awk -v d=${d#*/} -F":" '{a[$1]=a[$1] ? a[$1]", "$2 : $2} END \
      {for (i in a) {print "<a href=\47"d"/"i".html\47>"i"</a> "\
      "<a href=\47'$revoart'"substr(i,3)"\47 class=\47redakti\47 target=\47_new\47\
      title=\47artikolo\47>&#x270E;</a>: "a[i]"<br>"}}' - \
      >> "$outfile"
    # $ sort -u input.txt
    # $ awk '!a[$0]++' input.txt    
    
    # grouping with awk: https://www.thelinuxrain.com/articles/grouping-with-awk

    cnt_artikoloj=`grep -l "<span class=.*</span>" "$d"/* | wc -l`

    cat <<EOF >> "$outfile"
          <p>
            artikoloj kun trovoj: $cnt_artikoloj
          </p>
        </body>
      </html>
EOF

  # nur-teksta...
  else
    # malplena...
    outfile="${d}_trovoj.txt"
    echo "skribante al $outfile"
    echo "" > "$outfile"

    # forigu prefiksan ujon, html-strukturilojn kaj duoblaĵojn
    # provizore ne grupigu laŭ dosiero
    grep -oH "<span class=.*</span>" "$d"/* | sed 's/.*html\///' |\
      sed 's/<span[^>]*>//' | sed 's/<\/span>//' | awk '!a[$0]++' - \
    >> "$outfile"

  fi
}  

for dir in html/[a-z]
do
  if [ -d "$dir" ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "rigardante $dir..."
    elfiltru "$dir" html
  fi
done








