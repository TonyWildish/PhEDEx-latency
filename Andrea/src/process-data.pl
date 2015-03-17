#! /usr/bin/perl -I /home/sartiran/Andrea/modules

use Data::Dumper;

use strict;

use warnings;

my $datadir='data';

sub date_hr{
    my $time=shift;
    my ($sec, $min, $hour, $day,$month,$year) = (localtime($time))[0,1,2,3,4,5]; 
    return ($year+1900)."-".($month+1)."-".$day."-".$hour.":".$min.":".$sec;
};


my @new_fields=(
'time_subscription_hr',
'block_create_delta',
'block_close_delta',
'first_request_delta',
'first_replica_delta',
'percent25_replica_delta',
'percent50_replica_delta',
'percent75_replica_delta',
'percent95_replica_delta',
'last_replica_delta',
'primary_from_fraction',
'avg_file_size',
'eff_avg_rate',
'trans_avg_rate',
'skew_25',
'skew_50',
'skew_75',
'skew_95',
'rskew_25',
'rskew_50',
'rskew_75',
'rskew_95',
'skew_last_5',
'skew_last_25',
'skew_last_50',
'skew_last_75',
'rskew_last_5',
'rskew_last_25',
'rskew_last_50',
'rskew_last_75',
);

open INFILE, "${datadir}/block_latency-aggregated.csv" ;

open OUTFILE, ">${datadir}/block_latency-processed.csv";

open REJFILE, ">${datadir}/block_latency-rejected.csv";

my $header_line=1;
my @old_headers;
my @new_headers=();
while(<INFILE>){
    my $line=$_;


    if($header_line){
	@old_headers=split(',',$line);
	chomp(@old_headers);
	push(@new_headers,@old_headers);
	push(@new_headers,@new_fields);
	print OUTFILE join(',',@new_headers),"\n";
	print REJFILE join(',',@old_headers),"\n";
	$header_line=0;
	next;
    }
    my @fields=split(',',$line);
    chomp(@fields);
    my %FIELDS=();

    for(my $i=0;$i<scalar(@fields);$i++){
	$FIELDS{$old_headers[$i]}=$fields[$i];
    };

    #Reject ill defined data
    my $rejected=0;

    foreach my $key (keys(%FIELDS)){
	if($FIELDS{$key} eq "" ){
	    $rejected=1;
	}
    }

    if($FIELDS{block} eq 'block_unknown'){
	$rejected=1;
    }

    if($FIELDS{destination} eq 'node_undef'){
	$rejected=1;
    }

    if($FIELDS{primary_from_node} eq 'node_undef'){
	$rejected=1;
    }


    if($rejected){
#   Printout the line on the "rejected entries" file
	print REJFILE $FIELDS{$old_headers[0]};
 
	for(my $i=1;$i<scalar(@old_headers);$i++){
	    print REJFILE ",",$FIELDS{$old_headers[$i]};
	}
	
	print REJFILE "\n";
	
	next;
    }


#The line has not been rejected. Processing 
#Human readable timestamp
    $FIELDS{time_subscription_hr}=date_hr($FIELDS{time_subscription});

    $FIELDS{time_subscription}= int(1*$FIELDS{time_subscription});

    foreach my $item ('block_create','block_close','first_request','first_replica','percent25_replica','percent50_replica','percent75_replica','percent95_replica','last_replica'){
	$FIELDS{$item}=int(1*$FIELDS{$item});
	$FIELDS{$item.'_delta'}=1*$FIELDS{$item} - 1*$FIELDS{time_subscription};
    }
    
    my $delta=1.0*$FIELDS{last_replica_delta};

    if($delta != 0){

	$FIELDS{eff_avg_rate}=($FIELDS{bytes}*1.0)/($delta);

    }else{

	$FIELDS{eff_avg_rate}='infinite_eff_rate';
    }

    $delta=1*$FIELDS{last_replica} - 1*$FIELDS{first_request};

    if($delta != 0){

	$FIELDS{trans_avg_rate}=($FIELDS{bytes}*1.0)/(1.0*$delta);

    }else{
	
	$FIELDS{trans_avg_rate}='infinite_trans_rate';
	
    }
    
    $FIELDS{primary_from_fraction}=($FIELDS{primary_from_files}*1.0)/($FIELDS{files}*1.0);

    $FIELDS{avg_file_size}=($FIELDS{bytes}*1.0)/($FIELDS{files}*1.0);

#The swek and rskew variables
    foreach my $item ('25','50','75','95'){

	if((1*$FIELDS{'percent'.$item.'_replica'}-1*$FIELDS{'first_replica'})==0){
	    $FIELDS{'skew_'.$item}='skew_'.$item.'_infinite';
	    $FIELDS{'rskew_'.$item}='rskew_'.$item.'_infinite';
	}else{

	    $FIELDS{'skew_'.$item}=($item*1.0*($FIELDS{'last_replica'} - $FIELDS{'percent95_replica'}))/(5.0*($FIELDS{'percent'.$item.'_replica'}-$FIELDS{'first_replica'}));
	    $FIELDS{'rskew_'.$item}=($item*1.0*($FIELDS{'percent25_replica'}-$FIELDS{'first_replica'}))/(25.0*($FIELDS{'percent'.$item.'_replica'}-$FIELDS{'first_replica'}));
	}
    }

#The skew_last and rskew_last variables
    foreach my $item ('5','25','50','75'){

	my $complem=100-1*$item;

        if((1*$FIELDS{'last_replica'}-1*$FIELDS{'percent'.$complem.'_replica'})==0){
            $FIELDS{'skew_last_'.$item}='skew_last_'.$item.'_infinite';
            $FIELDS{'rskew_last_'.$item}='rskew_last_'.$item.'_infinite';
        }else{

            $FIELDS{'skew_last_'.$item}=($item*1.0*($FIELDS{'last_replica'} - $FIELDS{'percent95_replica'}))/(5.0*($FIELDS{'last_replica'}-$FIELDS{'percent'.$complem.'_replica'}));
            $FIELDS{'rskew_last_'.$item}=($item*1.0*($FIELDS{'percent25_replica'}-$FIELDS{'first_replica'}))/(25.0*($FIELDS{'last_replica'}-$FIELDS{'percent'.$complem.'_replica'}));
        }
    }

#   Printout the line
    print OUTFILE $FIELDS{$new_headers[0]};
 
    for(my $i=1;$i<scalar(@new_headers);$i++){
	print OUTFILE ",",$FIELDS{$new_headers[$i]};
    }

    print OUTFILE "\n";

}


close INFILE;

close OUTFILE;

close REJFILE;

