#!/bin/sh
#
#
#

dir=/mnt/RAID1/wikisearch

cd $dir

### CREATION DES ARCHIVES ###
tar cvzf $dir/document.tgz document
tar cvzf $dir/livres.tgz livres
tar cvzf $dir/index.tgz recherche portail rech_livres

echo "MAJ Ok" | /bin/mail -s "Fin creation index wikipedia `date +%d/%m/%Y`" paul.personne@test.com

exit

### MAKE INDEX ###
swish-e -f index/index.recherche.tmp -i recherche/
mv index/index.recherche.tmp index/index.recherche
mv index/index.recherche.tmp.prop index/index.recherche.prop

swish-e -f index/index.portail.tmp -i portail/
mv index/index.portail.tmp index/index.portail
mv index/index.portail.tmp.prop index/index.portail.prop

swish-e -f index/index.rech_livres.tmp -i rech_livres/
mv index/index.rech_livres.tmp index/index.rech_livres
mv index/index.rech_livres.tmp.prop index/index.rech_livres.prop

exit

### MAKE INDEX ###
swish-e -f index/index.recherche.tmp -i recherche/
mv index/index.recherche.tmp index/index.recherche
mv index/index.recherche.tmp.prop index/index.recherche.prop

swish-e -f index/index.bandeau.tmp -i bandeau/
mv index/index.bandeau.tmp index/index.bandeau
mv index/index.bandeau.tmp.prop index/index.bandeau.prop

### BATIMENT ###
swish-e -f index/index.batiment.tmp -i batiment/
mv index/index.batiment.tmp index/index.batiment
mv index/index.batiment.tmp.prop index/index.batiment.prop

