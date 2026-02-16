#!/bin/sh
#geoip.sh by Chris Gage
#Converts an IP CSV file to the GEOIPfree format
#
#To use update variables below to suite your system and add an
#entry like the following to your cron
#15 23 21 * * /usr/local/scripts/geoip.sh >/dev/null 2>&1
#
# TMP_DIR/TEMPFILE can be no longer than 99 characters
#
INFILE=ips.csv
TEMPFILE=raw_temp.$$
TEMPFILE2=raw_temp2.$$
FINALFILE=ipscountry.dat
WGET=/usr/bin/wget
MAIL=/bin/mail
ADDRESS=paul.personne@test.com
GEODIR=/usr/lib/perl5/site_perl/5.8.8/Geo
#URL=http://software77.net/cgi-bin/ip-country/geo-ip.pl?action=download
URL=http://software77.net/geo-ip?DL=1
GZIP=/bin/gunzip
PERL=/usr/bin/perl
TXT_DB_SCRIPT=/usr/lib/perl5/site_perl/5.8.8/Geo/txt2ipct.pl
CSV_TO_TXT_SCRIPT=/home/paul/dev/geocompute/geo-compute
TMP_DIR=/tmp

if [ -f ${TMP_DIR}/${INFILE}.gz ]
then
rm -f ${TMP_DIR}/${INFILE}.gz
fi

$WGET -O ${TMP_DIR}/${INFILE}.gz $URL > /dev/null 2>&1

EXITSTATUS=$?
if [ $EXITSTATUS != "0" ]
then
echo "GEO IP Free failed to update while downloading from $URL"|$MAIL -s "GEOIPfree update failed `date +%m/%d/%Y`" $ADDRESS

if [ -f ${TMP_DIR}/$TEMPFILE ]
then
rm ${TMP_DIR}/$TEMPFILE
fi
if [ -f ${TMP_DIR}/$TEMPFILE2 ]
then
rm ${TMP_DIR}/$TEMPFILE2
fi
if [ -f ${TMP_DIR}/${INFILE}.gz ]
then
rm ${TMP_DIR}/${INFILE}.gz
fi
exit 1
fi

$GZIP -f ${TMP_DIR}/${INFILE}.gz > /dev/null 2>&1

grep -v "^#" ${TMP_DIR}/$INFILE|sed 's/\"//g'|cut -d, -f1,2,5 > ${TMP_DIR}/$TEMPFILE2

#(
#echo ${TMP_DIR}/$TEMPFILE2
#echo ${TMP_DIR}/$TEMPFILE
#) 2>&1 | $CSV_TO_TXT_SCRIPT

$CSV_TO_TXT_SCRIPT ${TMP_DIR}/$TEMPFILE2 ${TMP_DIR}/$TEMPFILE

EXITSTATUS=$?
if [ $EXITSTATUS != "0" ]
then
echo echo "GEO IP Free failed to update while running $CSV_TO_TXT_SCRIPT"|$MAIL -s "GEOIPfree update failed `date +%m/%d/%Y`"

if [ -f ${TMP_DIR}/$TEMPFILE ]
then
rm ${TMP_DIR}/$TEMPFILE
fi
if [ -f ${TMP_DIR}/$TEMPFILE2 ]
then
rm ${TMP_DIR}/$TEMPFILE2
fi
if [ -f ${TMP_DIR}/$INFILE ]
then
rm ${TMP_DIR}/$INFILE
fi
if [ -f ${TMP_DIR}/$FINALFILE ]
then
rm ${TMP_DIR}/$FINALFILE
fi

exit 1
fi

$PERL $TXT_DB_SCRIPT ${TMP_DIR}/$TEMPFILE ${TMP_DIR}/$FINALFILE > /dev/null 2>&1

EXITSTATUS=$?
if [ $EXITSTATUS != "0" ]
then
echo "GEO IP Free failed to update while running $TXT_DB_SCRIPT"|$MAIL -s "GEOIPfree update failed `date +%m/%d/%Y`" $ADDRESS
if [ -f ${TMP_DIR}/$TEMPFILE ]
then
rm ${TMP_DIR}/$TEMPFILE
fi
if [ -f ${TMP_DIR}/$TEMPFILE2 ]
then
rm ${TMP_DIR}/$TEMPFILE2
fi
if [ -f ${TMP_DIR}/$INFILE ]
then
rm ${TMP_DIR}/$INFILE
fi
if [ -f ${TMP_DIR}/$FINALFILE ]
then
rm ${TMP_DIR}/$FINALFILE
fi
exit 1
fi

if [ -f ${TMP_DIR}/$TEMPFILE ]
then
rm ${TMP_DIR}/$TEMPFILE
fi
if [ -f ${TMP_DIR}/$TEMPFILE2 ]
then
rm ${TMP_DIR}/$TEMPFILE2
fi

if [ -f ${TMP_DIR}/$INFILE ]
then
rm ${TMP_DIR}/$INFILE
fi

if [ -f ${GEODIR}/$FINALFILE ]; then
mv ${GEODIR}/$FINALFILE ${GEODIR}/${FINALFILE}.bak
fi

mv ${TMP_DIR}/$FINALFILE ${GEODIR}/$FINALFILE

echo "GEO IP Free Successfully updated.\nThe new file is located at ${GEODIR}/${FINALFILE}"|$MAIL -s "GEOIPfree successfully updated on `date +%m/%d/%Y`" $ADDRESS
exit 0
