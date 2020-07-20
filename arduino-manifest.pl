#!/usr/bin/perl 
#
#
# ----------------------------------------------------------------------------
# Find library paths
# ----------------------------------------------------------------------------
#
use Getopt::Std;
getopts('hdb:rv');

sub usage {
    print "usage: arduino-manifest [-h] [-d] [-r] [-v] -b fqbn [file1 file2 ... filen]\n";
    print "  reads arduino surce files, usually .ino and .h files, indentify #include\n";
    print "  statements and print a list of used libaries and their versions.\n";
    print "  It is not recursive, the list doesn't include nested dependencies\n";
    print "  It needs the arduino-cli installed and in the PATH, it parses the\n";
    print "  output of the arduino-cli, so changes in arduino-cli can affect this script.\n";
    print "Options\n";
    print "  -b  fqbn  Fully Qualified Board Name, e.g.: arduino:avr:uno\n";
    print "  -h        print this help file\n";
    print "  -d        print debugging information\n";
    print "  -r        print the requirements.txt file, list only user library names\n";
    print "  -v        include version numbers with -r option\n";
    print "Arguments\n";
    print "  file1 file2 .. filen  source input files to parse, usually *.ino and\n";
    print "                        eventually, *.h\n";
}
sub openproperties {
    open F, "arduino-cli compile -b $opt_b --show-properties |" || die "Error executing arduino-cli \n";
}

sub openconfig {
    open F, "arduino-cli config dump |" || die "Error executing arduino-cli \n";
}

if ($opt_h) {usage; exit;}
unless ($opt_b) {usage; exit 1;}
if ($opt_d) {
    $debug=1;
}
else {
    $debug=0;
}
	

# expandproperty: recursively resolve simbolic names in @libpaths like {compiler.sdk.path}
sub expandproperty {
    my $sin=$_[0];
    my $n;
    my $svar;
    my $sout;
    $sout=$sin;
    do {
	$n=0;
	print STDERR "\nsin:  $sin\n" if ($debug);
	if ($sin=~/{([^}]+)/) {
	    $svar=$1;
	    print STDERR "svar: $svar\n" if ($debug);
	    $sout=$sin;
	    $sout=~s/\{$svar\}/$properties{$svar}/g;
	    print STDERR "sout: $sout\n" if ($debug);
	    $sin=$sout;
	    $n++;
	}
    } while ($n > 0);
    return $sout;
}


# build the %properties hash
openproperties();
while (<F>) {
    chomp;
    @line=split /=/;
    $properties{$line[0]}=$line[1];
}
close F;

# get the userlib from config
openconfig();
while (<F>) {
    chomp;
    if (/^\s*user:\s*([^\s]+)/) {
	$userlib=$1;
	print STDERR "userlib: $userlib\n" if ($debug);
	$libproperty{$userlib}="user";
    }
}
close F;

# @libpaths contain library root paths
push @libpaths,("$userlib/libraries");
$libproperty{"$userlib/libraries"}="user";
push @libpaths,(expandproperty($properties{'runtime.platform.path'}) . "/libraries");
$libproperty{expandproperty($properties{'runtime.platform.path'}) . "/libraries"}="system";

# print library paths
print STDERR "\n\n" if ($debug);
for $s (@libpaths) {
    print STDERR "$s\n" if ($debug);
}

# build the @libraries array with all library paths
for $dir (@libpaths) {
    if (-d $dir) {
	opendir(DIR,$dir) or die "Error opening dir $dir: $!\n";
	while ($file = readdir(DIR)) {
	    if (($file eq '.') or ($file eq '..')) { next; }
	    if (-d "$dir/$file") {
		push @libraries,("$dir/$file");
		$libproperty{"$dir/$file"}=$libproperty{"$dir"};
	    }
	}
	close DIR;
    }
}

# print all the libraries
print STDERR "\nLibraries:\n" if ($debug);
for $s (@libraries) {
    print STDERR "  $s\n" if ($debug);
}

print STDERR "\nInclude files:\n" if ($debug);
# read '#include <...>" lines from input files
while (<>) {
    if (/^\s*\#include\s+\<([^\>]+)/) {
	$includef=$1;
	print STDERR "  $includef \n" if ($debug);
	$includef{$includef}=1;
    }
}

# find used libraries
print STDERR "\nUsed Libraries\n" if ($debug);
for $includef (keys %includef) {
    $found=0;
    for $lib (@libraries) {
	if ( (-e "$lib/$includef") or (-e "$lib/src/$includef")) {
	    push @usedlib,($lib);
	    print STDERR "  $includef: $lib\n" if ($debug);
	    $found++;
	}
    }
    if ($found == 0) {
	print STDERR "  NOT FOUND: $includef\n";
    }
}

# print libraries details
print STDERR "\nLibraries details\n" if ($debug);
if (! $opt_r) {
    $prop{'name'}         ="Library Name";
    $prop{'version'}      ="Version";
    $prop{'author'}       ="Author";
    $prop{'architectures'}="Architecture";
    $prop{'libtype'}      ='Type';
    write;
    $prop{'name'}         ='-'x35;
    $prop{'version'}      ='-'x35;
    $prop{'author'}       ='-'x35;
    $prop{'architectures'}='-'x35;
    $prop{'libtype'}      ='-'x35;
    write;
}

for $lib (sort @usedlib) {
    undef %prop;
    undef @l;
    if ($processed{$lib}) { next; }
    if (-e "$lib/library.properties") {
	open PROP,"$lib/library.properties" or die "Error opening $lib/library.properties: $!\n";
	while (<PROP>) {
	    chomp;
	    @l=split /\s*=\s*/;
	    if ($l[0]) {
		$prop{$l[0]}=$l[1];
	    }
	}
	close PROP;
	$prop{'libtype'}=$libproperty{$lib};
	if (! $opt_r) {
	    write;
	} else {
	    if ($prop{'libtype'} eq 'user') {
		print "$prop{'name'}";
		if ($opt_v) {
		    print '@',$prop{'version'};
		}
		print "\n";
	    }
	}
    } else {
	print STDERR "  NOT EXIST: $lib/library.properties\n";
    }
    $processed{$lib}=1;
}


format STDOUT =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<< @<<<<<<
$prop{'name'}, $prop{'version'}, $prop{'author'}, $prop{architectures}, $prop{'libtype'}
.
