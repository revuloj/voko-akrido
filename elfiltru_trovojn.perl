#!/usr/bin/perl

$outhtml = 1;

@files = @ARGV;

if ($outhtml) {
  print <<EOH;
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
}

for $file (@files) {
    @eraroj = ();

    open IN,"$file";

    while(<IN>) {
      s|(<span class=\"neanaliz\">.*?</span>)|push(@eraroj,$1)|seg;
      s|(<span class=\"malstrikte\">.*?</span>)|push(@eraroj,$1)|seg;
      s|(<span class=\"dubebla\">.*?</span>)|push(@eraroj,"$1(?)")|seg;
    }

    close IN;


    if (@eraroj) {

        if ($outhtml) {
	    print "<a href='$file'>$file</a>: ";
	} else {
	    print "$file: ";
	}

        print join(', ',@eraroj);

	if ($outhtml) {
	    print "<br/>\n";
	} else {
	    print "\n";
	}
    }
}

if ($outhtml) {
    print <<EOF;
  </body>
</html>
EOF
}


