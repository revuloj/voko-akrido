#!/usr/bin/perl

@files = @ARGV;

for $file (@files) {
    @eraroj = ();
    open IN,"$file";
#    print "# $file:\n";
    while(<IN>) {
      s|<span class=\"neanaliz\">(.*?)</span>|push(@eraroj,$1)|seg;
#       s|<span class=\"neanaliz\">(.*?)</span>|print("$file: $1\n")|seg;
    }
    close IN;

#    print @eraroj;
    if (@eraroj) {
	print "$file: ";
        print join(', ',@eraroj);
        print "\n";
#	for $e (@eraroj)
    }
}



