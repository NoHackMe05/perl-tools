#!/bin/sh
#
#
#

dir="/mnt/RAID1/dmoz"
data=$dir/data

export dir data

cd $data
#wget "http://rdf.dmoz.org/rdf/content.rdf.u8.gz"
#gunzip content.rdf.u8.gz

cd $dir

perl ./traite_file.pl < $data/content.rdf.u8 > liste_dmoz_url.txt

sort -u < liste_dmoz_url.txt > liste_dmoz_url.srt
