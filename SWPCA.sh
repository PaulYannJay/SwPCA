#!/bin/bash
##########
##
##
##	This workflow allow to create circos karyotype comparison plot based on the assembly
## 
##
#######################################

l=1 #Default minimal length of alignment
t=1 #Default number of thread
while [ $# -gt 0 ] ; do
  case $1 in
    -a1 | --assembly1) A1="$2" ;echo "the assembly 1 : $A1" >&2;;
    -a2 | --assembly2) A2="$2" ;echo "the assembly 2 : $A2" >&2;;
    -s1 | --scaffold1) S1="$2" ;echo "the file containing the scaffolds of assembly 1 to analyse is : $S1" >&2;;
    -s2 | --scaffold2) S2="$2" ;echo "the file containing the scaffolds of assembly 2 to analyse is : $S2" >&2;;
	-l | --length) l="$2" ;echo "the minimum length for an alignment is : $l" >&2;;
	--1to1) OtO=T; echo "Only 1 to 1 alignement is allowed" >&2;;
	-p | --prefix) p="$2" ; echo "the output prefix is : $p" >&2;;
	-t | --threads) t="$2" ; echo "Perform alignment using $t threads" >&2;;
	-h | --help) echo -e "Option required:
-a1/--assembly1 \t First assembly to analyse
-a2/--assembly2 \t Second assembly to analyse 
-p/--prefix \t Output prefix
Optional: 
-s2/--scaffold2 \t set of Scaffold from assembly 2 to analyse. If not defined, all Scaffold are used
-s1/--scaffold1 \t set of Scaffold from assembly 1 to analyse. If not defined, all Scaffold are used 
-t/--threads \t number of thread to use
-l/--length \t Minimum length of aligment to display
--1to1 \t Only use one to one alignment (One query sequence can only math with one reference sequence and vice versa)\n\n" >&2;exit 1;; 
  esac
  shift
done

if [ -z "$p" ]; then
  echo >&2 "Fatal error: prefix not defined"
  exit 2
fi

echo "\n"

name1=`basename $A1 .fa` #Extract the sample name
name2=`basename $A2 .fa`
seq1=$A1 #The default sequence to be analysed is the whole sequence
seq2=$A2

if [ -n "$S1" ]; then
~/Code/Perl/TriFastaName.pl -i $A1 -n $S1 -o $name1.FocalScaffold.fa #Extract the focal scaffold from assembly1
seq1=$name1.FocalScaffold.fa
echo "Sequence from genome 1 : Extracted!"
fi

if [ -n "$S2" ]; then
~/Code/Perl/TriFastaName.pl -i $A2 -n $S2 -o $name2.FocalScaffold.fa #Extract the focal scaffold from assembly0
seq2=$name2.FocalScaffold.fa
echo "Sequence from genome 2 : Extracted!"
fi

~/Software/mummer-4.0.0beta2/bin/nucmer -t $t -p $p	$seq1 $seq2 #Align the sequence on $t thread
echo "Alignment done!"

if [ -n "$OtO" ]; then #Filter the sequence : One to One or all
~/Software/mummer-4.0.0beta2/bin/delta-filter -1 $p.delta > $p.delta.filtered
else
~/Software/mummer-4.0.0beta2/bin/delta-filter -m $p.delta > $p.delta.filtered
fi

~/Software/mummer-4.0.0beta2/bin/show-coords -r -T -H -L $l $p.delta.filtered > $p.delta.filtered.coords #transform in Human readable format

echo "Alignement filtering : done"

~/Project/GenomeAlign/Code/MummerCoord2CircosCoord.pl -i  $p.delta.filtered.coords -o $p.delta.filtered.coords.circos  #Transform in circos readable format
~/Project/GenomeAlign/Code/Assembly2CircosKaryotype2Species.pl -1 $seq1 -2 $seq2 -o $p.karyotype #Create karyotype for circos plot
echo "Everything done!"

