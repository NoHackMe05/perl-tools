#!/bin/sh
#
#
#

lang=$1

nb_process=`ps ax | grep "/my_detective.pl -lang" | perl -pe 's:^.*?grep.*?$::s;' | grep -c '/my_detective.pl'`

if [ $nb_process -gt 0 ]; then
	echo '#!/bin/sh' > /tmp/kill_whois.sh
	echo '#' >> /tmp/kill_whois.sh
	echo '#' >> /tmp/kill_whois.sh
	echo >> /tmp/kill_whois.sh

	ps ax | grep "/my_detective.pl -lang" | perl -pe 's:^.*?grep .*?$::s;s:^.*?kill_whois.*?$::s;s:^[^0-9]+::;s:^([0-9]+).*?$:kill -9 $1:g;' >> /tmp/kill_whois.sh

	chmod a+x /tmp/kill_whois.sh

	/tmp/kill_whois.sh

	rm -f /tmp/kill_whois.sh
fi

#nb_process=`ps ax | grep "/my_detective.pl -lang $lang" | perl -pe 's:^.*?grep.*?$::s;' | grep -c '/my_detective.pl'`

#if [ $nb_process -gt 0 ]; then
#	echo $nb_process
#	exit
#fi

dir=/home/paul/dev/my_detective

date=`date +%Y%m%d`

cd $dir

rm -f tmp/*

$dir/my_detective.pl -lang $lang 2>> $dir/log/index_${lang}_${date}.log

