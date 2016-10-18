#!/usr/bin/perl -s

use strict;

$::minlen  =  300 if(!defined($::minlen));
$::maxlen  = 1450 if(!defined($::maxlen));
$::species = 'homo sapiens' if(!defined($::species));

main();

sub UsageDie
{
    print <<__EOF;

getspeciesabs V1.0 (c) 2016, UCL, Dr. Andrew C.R. Martin

Usage: getspeciesabs [-species=xxxx] [-minlen=nnn] [-maxlen=nnn] file.xml
       -species - Specify the species to extract          [$::species]
       -minlen  - Specify minimum length sequence allowed [$::minlen]
       -maxlen  - Specify maximum length sequence allowed [$::maxlen]

Extracts the DNA sequence data from an abYsis XML data file

__EOF

    exit 0;
}

sub main
{
    my $id  = '';
    my $seq = '';
    my $org = '';

    UsageDie() if(defined($::h));

    while(<>)
    {
        if(/\<\/chain\>/)
        {
            PrintSeq($id, $seq, $org);
            $seq = '';
            $id  = '';
            $org = '';
        }
        elsif(/\<organism\>(.*)\<\/organism\>/)
        {
            $org = $1;
        }
        elsif(/\<entry.*source_id="(.*?)"/)
        {
            $id = $1;
        }
        elsif(/\<nuc_sequence.*?\>(.*)\<\/nuc_sequence\>/)
        {
            $seq = $1;
        }
    }
}

sub PrintSeq
{
    my($id, $seq, $org) = @_;

    if(($org eq $::species) &&
       ($seq ne '') &&
       ($id ne ''))
    {
        if((length($seq) > $::minlen) && (length($seq) < $::maxlen))
        {
            print ">$id\n";
            print "$seq\n";
        }
    }
}
