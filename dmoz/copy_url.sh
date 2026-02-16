#!/bin/sh
#
#
#

echo "** Copy des index sur serveur dedie **"
ftp -v -p -i -n <<EOF
open 192.168.2.101
user acr 3QIqyb9p
ascii
cd html
cd test_presence
cd liste_url
put liste_dmoz_url.srt
EOF
echo "Fin du transfert"
#fin du script  
