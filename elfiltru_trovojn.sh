#!/bin/bash

function elfiltru {
  d=$1
  outformat=$2

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
  else
    # malplena...
    outfile="${d}_trovoj.txt"
    echo "skribante al $outfile"
    echo "" > "$outfile"
  fi

  echo "elfiltru en $d..."
  # trovi dubindajn/erarajn vortojn, forigu duoblajn kaj grupigu laŭ dosiernomo
  grep -oH "<span class=.*</span>" "$d"/* | sed 's/.*html\///' | awk '!a[$0]++' - | \
    awk -F":" '{a[$1]=a[$1] ? a[$1]", "$2 : $2} END {for (i in a) {print i": "a[i]}}' - \
    >> "$outfile"
  # $ sort -u input.txt
  # $ awk '!a[$0]++' input.txt    
  
  # grouping with awk: https://www.thelinuxrain.com/articles/grouping-with-awk

  cnt_artikoloj=`grep -l "<span class=.*</span>" "$d"/* | wc -l`

  if [ $outformat == "html" ]; then
  	cat <<EOF >> "$outfile"
        <p>
          artikoloj kun trovoj: $cnt_artikoloj
        </p>
      </body>
    </html>
EOF
  fi

#  	print "<a href='$file'>$fileref</a> ";
#		print "<a href='$REVO/art/$fileref.html' class='redakti' ";
		#print "title='artikolo' target='_new'>&#x270E;</a>: ";

#		print join(', ',@eraroj2);
#		print "<br/>\n";
#	    } else {
#		print "$fileref: ";
#		my @err = map { m|>(.*?)</span|; $1 } @eraroj2;
#		print join(', ',@err);
#		print "\n";
#	    }

#           $cnt++;



}  

for dir in html/[a-z]
do
  if [ -d "$dir" ]; then
    echo "rigardante $dir..."
    elfiltru "$dir" html
  fi
done








