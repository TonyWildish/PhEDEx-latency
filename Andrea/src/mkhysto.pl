#! /usr/bin/perl -I /home/sartiran/Andrea/modules

use Data::Dumper;

use strict;

use warnings;

my $datadir='data';

my @new_fields=(
'is_custodial',
'data_type_tag',
'transfer_type_tag',
'files_number_tag',
'files_size_tag',
'block_size_tag',
'exclude_tag',
'while_open_tag',
'latency_tag',
'tiers_tag',
    );

my @counters=(
    'count',
    'files',
    'bytes',
    );

my $VAR1;

my $lines;

open(INFILE,"${datadir}/block_latency-hysto.pl") or die "cannot open file for reading";

while(<INFILE>)
{
    $lines.=$_;
}

close INFILE;

eval($lines);

#print Dumper($VAR1),"\n";

open OUTFILE, ">${datadir}/block_latency-hysto.csv" ;

my @new_headers=();

push(@new_headers,@new_fields);
push(@new_headers,@counters);
print OUTFILE join(',',@new_headers),"\n";

my $ptr=$VAR1;
for my $is_custodial (keys(%{$ptr})){
    my $ptr1=$ptr->{$is_custodial};
    for my $data_type_tag (keys(%{$ptr1})){
	my $ptr2=$ptr1->{$data_type_tag};
	for my $transfer_type_tag (keys(%{$ptr2})){
	    my $ptr3=$ptr2->{$transfer_type_tag};
	    for my $files_number_tag (keys(%{$ptr3})){
		my $ptr4=$ptr3->{$files_number_tag};
		for my $files_size_tag (keys(%{$ptr4})){
		    my $ptr5=$ptr4->{$files_size_tag};
		    for my $exclude_tag (keys(%{$ptr5})){
			my $ptr6=$ptr5->{$exclude_tag};
			for my $while_open_tag (keys(%{$ptr6})){
			    my $ptr7=$ptr6->{$while_open_tag};
			    for my $block_size_tag (keys(%{$ptr7})){
				my $ptr8=$ptr7->{$block_size_tag};
				for my $latency_tag (keys(%{$ptr8})){
				    my $ptr9=$ptr8->{$latency_tag};
				    for my $tiers_tag (keys(%{$ptr9})){
					my $ptr10=$ptr9->{$tiers_tag};
				    
					my @line=($is_custodial,$data_type_tag,$transfer_type_tag,$files_number_tag,$files_size_tag,$exclude_tag,$while_open_tag,$block_size_tag,$latency_tag,$tiers_tag);
					my @values=($ptr10->{count},$ptr10->{files},$ptr10->{bytes});
					push(@line,@values);
					print OUTFILE join(',',@line),"\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}

close OUTFILE;

