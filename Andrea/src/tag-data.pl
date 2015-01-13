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
#'tape_migration_tag',
'data_type_tag',
'transfer_type_tag',
'files_number_tag',
'files_size_tag',
'exclude_tag',
'while_open_tag',
);

open OUTFILE, ">${datadir}/block_latency-tagged.csv";

open INFILE, "${datadir}/block_latency-processed.csv" ;

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
	$header_line=0;
	next;
    }
    my @fields=split(',',$line);
    chomp(@fields);
    my %FIELDS=();

    for(my $i=0;$i<scalar(@fields);$i++){
	$FIELDS{$old_headers[$i]}=$fields[$i];
    };



#Data Type tag
    if($FIELDS{block} =~ /^\/\S+\/Run20\S+\/\S+$/){
	$FIELDS{data_type_tag}='realdata';
    }elsif($FIELDS{block} =~ /^\/\S+\/(Spring|Summer|Fall|Winter)\S+\/\S+$/){
	$FIELDS{data_type_tag}='mcdata';
    }else{
	$FIELDS{data_type_tag}='otherdata';
    }

#Files number tag
    $FIELDS{files_number_tag}='extrafiles';
    for my $cut (1000,500,100,50,20,10,6,5,4,3,2,1){
	if($FIELDS{files} <= $cut){
	    $FIELDS{files_number_tag}=$cut.'files';
	}
    }

#Files size tag
    $FIELDS{files_size_tag}='bigfiles';
    for my $size (10,5,2,1){
	if($FIELDS{avg_file_size} <= $size*1048576*1024){
	    $FIELDS{files_size_tag}=$size.'Gsize';
	}
    }

    for my $size (500,100){
	if($FIELDS{avg_file_size} <= $size*1048576){
	    $FIELDS{files_size_tag}=$size.'Msize';
	}
    }



#Transfer Type Tag
    $FIELDS{transfer_type_tag}='txf_other';

    if(($FIELDS{destination}=~/T1\_\S+/) && ($FIELDS{primary_from_node}=~/T0\_\S+/) && $FIELDS{primary_from_fraction}==1){
        $FIELDS{transfer_type_tag}='txf_t0t1dist';
    }

    if(($FIELDS{destination}=~/T1\_\S+/) && ($FIELDS{primary_from_node}=~/T2\_\S+/) && $FIELDS{is_custodial} eq 'y' && $FIELDS{data_type_tag} eq 'mcdata'){
        $FIELDS{transfer_type_tag}='txf_mcupload';
    }

    if(($FIELDS{destination}=~/(T\d\S+)\_MSS/) && ($FIELDS{primary_from_node}=~/$1\_\S+/) && $FIELDS{primary_from_fraction}==1){
	$FIELDS{transfer_type_tag}='txf_migr';
    }

    
#Transfer while open tag
    $FIELDS{while_open_tag}='while_open:none';

    $FIELDS{while_open_tag}='while_open:sub' if(1*$FIELDS{time_subscription} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:1st_req' if(1*$FIELDS{first_request} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:1st_rep' if(1*$FIELDS{first_replica} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:25perc' if(1*$FIELDS{percent25_replica} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:50perc' if(1*$FIELDS{percent50_replica} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:75perc' if(1*$FIELDS{percent75_replica} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:95perc' if(1*$FIELDS{percent95_replica} < 1*$FIELDS{block_close});

    $FIELDS{while_open_tag}='while_open:last' if(1*$FIELDS{last_replica} < 1*$FIELDS{block_close});

#Exclude Tag
    $FIELDS{exclude_tag}='excluded:ok';


#    $FIELDS{exclude_tag}='excluded:trivskew' if("$FIELDS{'skew_25'}" eq "0");

    foreach my $item ('25','50','75','95'){
	if($FIELDS{'skew_'.$item} eq 'skew_'.$item.'_infinite') {
	    $FIELDS{exclude_tag}='excluded:infskew'.$item;
	}
    }

    if( $FIELDS{eff_avg_rate} eq 'infinite_eff_rate'){
	$FIELDS{exclude_tag}='excluded:infrate';
    }

    if($FIELDS{files} <5){
	$FIELDS{exclude_tag}='excluded:small';    
    }
 
    if((1*$FIELDS{last_replica} - 1*$FIELDS{time_subscription}) < 3*3600){
	$FIELDS{exclude_tag}='excluded:short';    
    }

    if($FIELDS{total_suspend_time} > 0){
	$FIELDS{exclude_tag}='excluded:susp';    
    }


    if($FIELDS{block}=~/BUNNIES/){
	$FIELDS{exclude_tag}='excluded:bunny';
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
