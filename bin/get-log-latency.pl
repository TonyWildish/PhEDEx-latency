#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PHEDEX::Core::DB;

my ($out,$timestamp,$sql,@columns,$dbparam,$now,$self);
my ($type,$sth,@h,$i,$verbose,$debug,$help,$root);
$verbose = $debug = $help = 0;
$root = '/afs/cern.ch/user/w/wildish/work/public/Data/BlockLatency';
$type = 'block';
GetOptions(
	    'dbparam=s'	  => \$dbparam,
	    # 'timestamp=i' => \$timestamp,
	    'type=s'	    => \$type,
      'root=s'      => \$root,
	    'verbose'	    => \$verbose,
	    'debug'	      => \$debug,
	    'help'	      => \$help,
	  );

$ENV{TNS_ADMIN} = '/afs/cern.ch/project/oracle/admin';

sub usage {
  print <<EOF;

 Usage: $0 --type (file|block) --dparam <DBParam> --root <dir>

 writes the file or block latency information to a csv.gz file, taking
data from a certain timestamp onwards. Looks in the current directory for
existing files and takes the highest timestamp there as the starting time.

 'root' is the directory to look in for existing files, default is:
 $root

EOF
}

if ( $help ) {
  usage();
  exit 0;
}
if ( !defined($dbparam) ) {
  die "--dbparam is obligatory (with Prod/Reader is a good choice)\n";
}
if ( $type ne 'file' && $type ne 'block' ) {
  die "--type must be one of 'file|block'\n";
}
$now = time();

if ( $type eq 'file' ) {
  @columns = qw (
    time_subscription
    time_update
    destination
    fileid
    inblock
    filesize
    priority
    is_custodial
    time_request
    original_from_node
    from_node
    time_route
    time_assign
    time_export
    attempts
    time_first_attempt
    time_on_buffer
    time_at_destination
  );
  $sql = "select " .  join(', ',@columns) .
         " from t_log_file_latency where time_update > $timestamp";
} else {
  @columns = qw (
    time_update
    destination
    block
    files
    bytes
    priority
    is_custodial
    time_subscription
    block_create
    block_close
    first_request
    first_replica
    percent25_replica
    percent50_replica
    percent75_replica
    percent95_replica
    last_replica
    primary_from_node
    primary_from_files
    total_xfer_attempts
    total_suspend_time
    latency
  );
  $sql = "select " .  join(', ',@columns) .
         " from t_log_block_latency where time_update > $timestamp";
}

$out = "${type}_latency-$now.csv.gz";
$self = { DBCONFIG => $dbparam };
$self->{DBH} = PHEDEX::Core::DB::connectToDatabase($self);
$sth = $self->{DBH}->prepare($sql);
$sth->execute();
open OUT, "| gzip - > $out" or die "$out: $!\n";
print OUT join(',',@columns),"\n";
$i = 0;
select STDOUT; $|=1;
while ( @h = $sth->fetchrow() ) {
  if ( ! (++$i % 1000) ) { print "$i  \r"; }
  foreach ( @h ) {
    $_ = '' unless defined $_;
    print OUT $_,',';
  }
  print OUT "\n";
}
close OUT;
PHEDEX::Core::DB::disconnectFromDatabase($self, $self->{DBH}, 1);
print "\nAll done\n";
