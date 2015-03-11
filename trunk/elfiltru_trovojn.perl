#!/usr/bin/perl

$outhtml = 1;
$REVO = "http://retavortaro.de/revo";

$revo_txt_dir = $ENV{REVO}."/txt";
$touch_seventh = 0; # tushu (renovigu) chiun sepan fontodosieron kun eraroj tiel, 
                    # ke la vortanalizu rekreos ghin sekvafoje - tio helpas
                    # forigi erarojn el la erarolisto, kiuj kauzighis aliloke, ekz.
                    # pro mankanta radiko en la vortaro

#### opcioj:
# -t       teksta rezulto, aliokaze html
# -k <DIR> traktu chiujn dosierojn el ujo 
#          kaj kreu filtrolisto por chiu komenclitero
#          aliokaze traktu nur dosierojn de komandlinio
#          kaj skribu rezulton en unu liston

if ($ARGV[0] eq '-t') {
    $outhtml = 0;
    shift @ARGV;
} elsif ($ARGV[0] eq '-k') {
    $komplete = 1; shift @ARGV;
    $startdir = shift @ARGV;
}

if ($komplete) {
    chdir($startdir);

    # files from subdirectories	to <subdir>_trovoj.html
    for $subdir (glob "./*/" ) {
	$subdir =~ s/\/$//;
	print "$subdir -> ${subdir}_trovoj.html\n";

	open TRV,">${subdir}_trovoj.html";
	select TRV;
	$cnt = elfiltru(glob "${subdir}/*.html");
	select STDOUT;
	close TRV;
	print "  $cnt artikoloj\n";
   }

} else {
    # files from command line to STDOUT
    elfiltru(@ARGV);
}

exit(0);

################################

sub elfiltru {
    my @files = @_;
    my $cnt = 0;

    print_header() if ($outhtml);


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

 	    my $fileref = $file; $fileref =~ s|^.*/(.*?)\.html|$1|;

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


           # eble tushu (renovigu) fontodosieron, vd. supre
           if ($touch_seventh) {
	       my $source_file = "$revo_txt_dir/$fileref.txt";
	       touch_modulo_seven($source_file,$cnt++);
	   }

	}
    }

    print_footer($cnt) if ($outhtml);
    return $cnt;
}

sub print_header {
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

sub print_footer {
    my $cnt_artikoloj = shift;

	print <<EOF;
        <p>
          artikoloj kun trovoj: $cnt_artikoloj
        </p>
      </body>
    </html>
EOF
}

sub touch_modulo_seven {
    my ($file,$counter) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

    if ($counter % 7 == $wday) {
	# tushu dosieron
	my $atime = 0; # time;
	my $mtime = $atime;
	utime($atime,$mtime,$file) ||
           warn "Ne povis tushi '$file'-on: $!\n";
    }
}
