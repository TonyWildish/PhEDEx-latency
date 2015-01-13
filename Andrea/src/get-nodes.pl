#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PHEDEX::Core::DB;

my ($out,$sql,@columns,$dbparam,$self);
my ($sth,@h,$i,$verbose,$debug,$help);

$verbose = $debug = $help = 0;
$out = "data/nodes-info";
GetOptions(
      'dbparam=s'	 => \$dbparam,
      'out=s'     => \$out,
      'verbose'	   => \$verbose,
      'debug'	     => \$debug,
      'help'	     => \$help,
	  );

#if ( !defined($ENV{TNS_ADMIN}) ) {
#  $ENV{TNS_ADMIN} = '/afs/cern.ch/project/oracle/admin';
#}

sub usage {
  print <<EOF;

 Usage: $0 --dparam <DBParam> --out <file>

 writes nodes information to a (gzipped) perl dictionary file.

 'out' is the output file. Default is $out.

EOF
}
if ( $help ) {
  usage();
  exit 0;
}
if ( !defined($dbparam) ) {
  die "--dbparam is obligatory (with Prod/Reader is a good choice)\n";
}

$self = { DBCONFIG => $dbparam };
$self->{DBH} = PHEDEX::Core::DB::connectToDatabase($self);


@columns = qw (
    id    
    bandwidth_cap
    capacity
    se_name
    technology
    kind
    name
  );
$sql = "select " .  join(', ',@columns) ." from t_adm_node";


$out = $out.".pl.gz";
$sth = $self->{DBH}->prepare($sql);
$sth->execute();
open OUT, "| gzip - > $out" or die "$out: $!\n";
print "Writing to ",$out,"\n";
print OUT '$NODES={'."\n";
$i = 0;
select STDOUT; $|=1;
while ( @h = $sth->fetchrow() ) {
  if ( ! (++$i % 10000) ) { print "  $i  \r"; }
  print OUT "'$h[0]' => {\n";
  foreach ( @h ) {
    $_ = '' unless defined $_;
  }
  for(my $i=0;$i<scalar(@h);$i++){
      print OUT "\t'".$columns[$i]."' => '".$h[$i]."',\n";
  } 
  print OUT "},\n";
}
print OUT "}\n";
close OUT;
PHEDEX::Core::DB::disconnectFromDatabase($self, $self->{DBH}, 1);
print "\nAll done\n";
