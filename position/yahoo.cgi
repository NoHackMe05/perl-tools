#!/usr/bin/perl
#
#

use CGI;

$query = new CGI;

$url = $query->param('url');
$motcle = $query->param('motcle');
$type = $query->param('type');

$option = '';
if ($type =~ /^fr$/i) {
	$option = "&meta=vc%3DcountryFR";
}

$start = 0;
$num = 100;

$test_url = $url;
$test_url =~ tr/A-Z/a-z/;
$test_url =~ s: +::g;
$test_url =~ s:^http\://::gi;
$test_url =~ s:/$::g;
$test_url =~ s:\/:\\\/:g;
$test_url =~ s:\.:\\\.:g;
$test_url =~ s:\::\\\::g;

print "Content-type: text/plain\n\n";

for ($i=0; $i<3; $i++) {
	$start = $num * $i;

	$texte = `lynx -source -accept_all_cookies "http://fr.search.yahoo.com/search?p=$motcle&n=40&b=$start$option"`;

	$texte =~ s:\%3A:\::gi;
	$texte =~ s:\%2F:\/:gi;

	if ($texte =~ /$test_url/i) {
		$count = 1;
		while ($texte =~ /<a +class=yschttl +href="([^"]+)">/i) {
			$the_url = $1;
			
			if ($the_url =~ /$test_url/i) {
				$calcul = $start + $count;
				
				print "<a href=\"http://fr.search.yahoo.com/search?p=$motcle&n=40&b=$start$option\" target=\"_blank\" 
class=\"lien_noir\">Position = $calcul</a>\n";
				exit;
			}
			
			$texte =~ s:<a +class=yschttl +href="[^"]+"::i;
			
			$count++;
		}
	}
}

print "Votre page n'a pas été trouvé. Elle doit certainement se trouver au delà des 120 résultats.\n";
