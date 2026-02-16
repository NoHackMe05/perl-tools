#!/bin/sh
#
#
#

echo "** Copy des index sur serveur dedie **"
ftp -v -p -i -n <<EOF
open 91.121.83.164
user acring ES0xaV0j
ascii
cd sd
cd wikisearch
cd www
put livres.tgz
EOF
echo "Fin du transfert"
#fin du script  
