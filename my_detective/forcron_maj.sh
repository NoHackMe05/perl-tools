#!/bin/sh
#
#
#

lang=$1

nb_process=`ps ax | grep "/my_detective.pl -is_maj -lang" | perl -pe 's:^.*?grep.*?$::s;' | grep -c '/my_detective.pl'`

if [ $nb_process -gt 0 ]; then
	echo '#!/bin/sh' > /tmp/kill_whois_maj.sh
        echo '#' >> /tmp/kill_whois_maj.sh
        echo '#' >> /tmp/kill_whois_maj.sh
        echo >> /tmp/kill_whois_maj.sh

        ps ax | grep "/my_detective.pl -is_maj -lang" | perl -pe 's:^.*?grep .*?$::s;s:^.*?kill_whois.*?$::s;s:^[^0-9]+::;s:^([0-9]+).*?$:kill -9 $1:g;' >> /tmp/kill_whois_maj.sh

        chmod a+x /tmp/kill_whois_maj.sh

        /tmp/kill_whois_maj.sh

        rm -f /tmp/kill_whois_maj.sh
fi

dir=/home/paul/dev/my_detective

date=`date +%Y%m%d`

cd $dir

rm -f tmp/*

$dir/my_detective.pl -is_maj -lang $lang -limit 0 2>> $dir/log/index_maj_${lang}_${date}.log

