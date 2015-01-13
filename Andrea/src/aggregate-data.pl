#! /usr/bin/perl -I /home/sartiran/Andrea/modules

use Data::Dumper;

use strict;

use warnings;

my $datadir='data/';

my @old_headers=(
'time_update',
'destination',
'block',
'files',
'bytes',
'priority',
'is_custodial',
'time_subscription',
'block_create',
'block_close',
'first_request',
'first_replica',
'percent25_replica',
'percent50_replica',
'percent75_replica',
'percent95_replica',
'last_replica',
'primary_from_node',
'primary_from_files',
'total_xfer_attempts',
'total_suspend_time',
'latency',
'src_tier',
'dst_tier'
);

my @new_headers=(
'time_update',
'destination',
#'destination_kind',
#'destination_technology',
'block',
'files',
'bytes',
'priority',
'is_custodial',
'time_subscription',
'block_create',
'block_close',
'first_request',
'first_replica',
'percent25_replica',
'percent50_replica',
'percent75_replica',
'percent95_replica',
'last_replica',
'primary_from_node',
#'primary_from_technology',
#'primary_from_kind',
'primary_from_files',
'total_xfer_attempts',
'total_suspend_time',
'latency',
'src_tier',
'dst_tier'
);

my $BLOCKS;
eval(qx(zcat ${datadir}/blocks-info.pl.gz));

my $NODES;
eval(qx(zcat ${datadir}/nodes-info.pl.gz));

open OUTFILE, ">${datadir}/block_latency-aggregated.csv";

open INFILE, "zcat ${datadir}/block_latency-[0-9]*.csv.gz|" ;

my $header_line=1;
while(<INFILE>){
    my $line=$_;

    if($header_line){
	print OUTFILE join(',', @new_headers),"\n";
	$header_line=0;
	next;
    }
    my @fields=split(',',$line);
    chomp(@fields);
    my %FIELDS=();

    for(my $i=0;$i<scalar(@fields);$i++){
	$FIELDS{$old_headers[$i]}=$fields[$i];
    };

    #here is the data manipulation
    my $destid=$FIELDS{destination};
    if(defined($NODES->{$destid})){
	$FIELDS{destination}=$NODES->{$destid}->{name};
	$FIELDS{destination_technology}=$NODES->{$destid}->{technology};
	$FIELDS{destination_kind}=$NODES->{$destid}->{kind};
    }else{
	$FIELDS{destination}='node_undef';
	$FIELDS{destination_technology}='node_undef';
	$FIELDS{destination_kind}='node_undef'
    }

    my $srcid=$FIELDS{primary_from_node};
    if(defined($NODES->{$srcid})){
	$FIELDS{primary_from_node}=$NODES->{$srcid}->{name};
	$FIELDS{primary_from_technology}=$NODES->{$srcid}->{technology};
	$FIELDS{primary_from_kind}=$NODES->{$srcid}->{kind};
    }else{
	$FIELDS{primary_from_node}='node_undef';
	$FIELDS{primary_from_technology}='node_undef';
	$FIELDS{primary_from_kind}='node_undef'
    }


    my $blockid=$FIELDS{block};
    if(defined($BLOCKS->{$blockid})){
	$FIELDS{block}=$BLOCKS->{$blockid};
    }else{
	$FIELDS{block}='block_unknown';
    }

    


    print OUTFILE $FIELDS{$new_headers[0]};

    for(my $i=1;$i<scalar(@new_headers);$i++){
	print OUTFILE ",",$FIELDS{$new_headers[$i]};
    }

    print OUTFILE "\n";

}



close INFILE;

close OUTFILE;

