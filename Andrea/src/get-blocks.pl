#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PHEDEX::Core::DB;

my ($out,$timestamp,$sql,@columns,$dbparam,$now,$self,$type);
my ($sth,@h,$i,$verbose,$debug,$help,$root,@files,$file);
my ($max_interval,%nodes,@node);

$max_interval = 120 * 86400; # dump ~1/3 a year at a time.
$timestamp = 1356994800; # 00:00:00, Jan 1st 2013
$type = "block";
$verbose = $debug = $help = 0;
$out = "data/blocks-info";
GetOptions(
      'dbparam=s'	 => \$dbparam,
      'out=s'     => \$root,
      'verbose'	   => \$verbose,
      'debug'	     => \$debug,
      'help'	     => \$help,
	  );

sub usage {
  print <<EOF;

 Usage: $0 --dparam <DBParam> --out <file>

 writes blocks information to a (gzipped) perl dictionary file.

 'out' is the output file. Default is $out

EOF
}
if ( $help ) {
  usage();
  exit 0;
}
if ( !defined($dbparam) ) {
  die "--dbparam is obligatory (with Prod/Reader is a good choice)\n";
}

$now = time();

$self = { DBCONFIG => $dbparam };
$self->{DBH} = PHEDEX::Core::DB::connectToDatabase($self);


@columns = qw (
    id
    name
  );
$sql = "select " .  join(', ',@columns) ." from t_dps_block";

$out = $out.'.pl.gz';
$sth = $self->{DBH}->prepare($sql);
$sth->execute();
open OUT, "| gzip - > $out" or die "$out: $!\n";
print "Writing to ",$out,"\n";
print OUT '$BLOCKS={'."\n";
$i = 0;
select STDOUT; $|=1;
while ( @h = $sth->fetchrow() ) {
  if ( ! (++$i % 10000) ) { print "  $i  \r"; }
  foreach ( @h ) {
    $_ = '' unless defined $_;
  }
  print OUT "'$h[0]' => '$h[1]',\n";
}
print OUT "}\n";
close OUT;
PHEDEX::Core::DB::disconnectFromDatabase($self, $self->{DBH}, 1);
print "\nAll done\n";
