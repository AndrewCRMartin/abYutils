#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    getspeciesabs
#   File:       getspeciesabs.pl
#   
#   Version:    V1.0
#   Date:       18.10.16
#   Function:   Extract human abs DNA (with variable domains) from abYsis
#               XML data
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2016
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0    18.10.16 Original   By: ACRM
#*************************************************************************
# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use Cwd qw(abs_path);
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");

use strict;

$::minlen  =  300 if(!defined($::minlen));
$::maxlen  = 1450 if(!defined($::maxlen));
$::species = 'homo sapiens' if(!defined($::species));

main();

#*************************************************************************
sub main
{
    my $id         = '';
    my $seq        = '';
    my $org        = '';
    my $gotVDomain = 0;

    UsageDie() if(defined($::h));

    while(<>)
    {
        if(/\<\/chain\>/)
        {
            PrintSeq($id, $seq, $org, $gotVDomain);
            $seq        = '';
            $id         = '';
            $org        = '';
            $gotVDomain = 0;
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
        elsif(/<residue.*chothia=/)
        {
            $gotVDomain = 1;
        }
    }
}

#*************************************************************************
sub PrintSeq
{
    my($id, $seq, $org, $gotVDomain) = @_;

    if($gotVDomain          &&
       ($org eq $::species) &&
       ($seq ne '')         &&
       ($id  ne ''))
    {
        if((length($seq) > $::minlen) && (length($seq) < $::maxlen))
        {
            print ">$id\n";
            print "$seq\n";
        }
    }
}

#*************************************************************************
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

