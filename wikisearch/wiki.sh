#!/bin/sh
#
#
#

dir=/mnt/RAID1/wikisearch
data=$dir/data
document=$dir/document
recherche=$dir/recherche
portail=$dir/portail
livres=$dir/livres
rech_livres=$dir/rech_livres
tmp=$dir/tmp

export dir data document recherche portail livres rech_livres tmp

perl ./traite_file.pl $document $recherche $portail $livres $rech_livres thesaurus.txt portail.txt livres.txt liste_url.txt < $data/frwiki-20091013-pages-articles.xml

sort -u < thesaurus.txt > thesaurus.srt
sort -u < portail.txt > portail.srt
sort -u < livres.txt > livres.srt
sort -u < liste_url.txt > liste_url.srt
