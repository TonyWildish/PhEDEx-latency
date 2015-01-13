#! /usr/bin/perl -I /home/sartiran/Andrea/modules

use Data::Dumper;

use strict;

use warnings;

my $datadir="data";

sub date_hr{
    my $time=shift;
    my ($sec, $min, $hour, $day,$month,$year) = (localtime($time))[0,1,2,3,4,5]; 
    return ($year+1900)."-".($month+1)."-".$day."-".$hour.":".$min.":".$sec;
};


my @new_fields=(
'is_custodial',
'data_type_tag',
'transfer_type_tag',
'files_number_tag',
'files_size_tag',
'exclude_tag',
'while_open_tag',

#Counters
#'num_txfs',
#'num_files',
#'tot_size',
    );

#ime_update,destination,destination_kind,destination_technology,block,files,bytes,priority,is_custodial,time_subscription,block_create,block_close,first_request,first_replica,percent25_replica,percent50_replica,percent75_replica,percent95_replica,last_replica,primary_from_node,primary_from_technology,primary_from_kind,primary_from_files,total_xfer_attempts,total_suspend_time,latency,src_tier,dst_tier,time_subscription_hr,block_create_delta,block_close_delta,first_request_delta,first_replica_delta,percent25_replica_delta,percent50_replica_delta,percent75_replica_delta,percent95_replica_delta,last_replica_delta,primary_from_fraction,avg_file_size,eff_avg_rate,trans_avg_rate,skew_25,skew_50,skew_75,skew_95

my @counters=(
    'count',
    'files',
    'bytes',
    );

open INFILE, "${datadir}/block_latency-tagged.csv" ;

my $header_line=1;
my @old_headers;
#my @new_headers=();
my %hysto=();
my $count=0;

while(<INFILE>){
    my $line=$_;


    if($header_line){
	@old_headers=split(',',$line);
	chomp(@old_headers);
	#push(@new_headers,@old_headers);
	#push(@new_headers,@new_fields);
	#print OUTFILE join(',',@new_headers),"\n";
	$header_line=0;
	next;
    }
    my @fields=split(',',$line);
    chomp(@fields);
    my %FIELDS=();

    for(my $i=0;$i<scalar(@fields);$i++){
	$FIELDS{$old_headers[$i]}=$fields[$i];
    };

    my $ptr=\%hysto;

    foreach my $i (@new_fields){
	$ptr->{$FIELDS{$i}}={} unless(defined($ptr->{$FIELDS{$i}}));
	$ptr=$ptr->{$FIELDS{$i}};
    };

    foreach my $counter (@counters) {
	$ptr->{$counter}=0 unless(defined($ptr->{$counter}));
	if($counter eq 'count'){
	    $ptr->{$counter}++;
	}else{
	    $ptr->{$counter}+=$FIELDS{$counter};
	}
    };
    $count++;

}

close INFILE;

open OUTFILE, ">${datadir}/block_latency-hysto.pl" ;

print OUTFILE Dumper(\%hysto);

close OUTFILE;

