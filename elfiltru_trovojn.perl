#!/usr/bin/perl

$outhtml = 1;
$REVO = "http://retavortaro.de/revo";

if ($ARGV[0] eq '-t') {
    $outhtml = 0;
    shift @ARGV;
}

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

	$fileref = $file; $fileref =~ s|^.*/(.*?)\.html|$1|;

        if ($outhtml) {
	    print "<a href='$file'>$fileref</a> ";
	    print "<a href='$REVO/art/$fileref.html' class='redakti' ";
	    print "title='artikolo' target='_new'>&#x270E;</a>: ";

	    print join(', ',@eraroj);
	    print "<br/>\n";
	} else {
	    print "$fileref: ";
	    my @err = map { m|>(.*?)</span|; $1 } @eraroj;
	    print join(', ',@err);
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


