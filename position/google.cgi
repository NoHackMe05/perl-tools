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
	$option = "&meta=cr%3DcountryFR";
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

	$texte = `lynx -source -accept_all_cookies "http://www.google.fr/search?hl=fr&rls=GGGL%2CGGGL%3A2005-09%2CGGGL%3Afr&q=$motcle&btnG=Rechercher&meta=&num=100&start=$start$option"`;

	$texte =~ s:\%3A:\::gi;
	$texte =~ s:\%2F:\/:gi;

	if ($texte =~ /$test_url/i) {
		$texte =~ s:<blockquote class=g>.*?</blockquote>::sgi;
		
		$texte =~ s:<\!--[^\n]+-->::g;
		$texte =~ s:(<p class=g><a) class=l:$1:g;

		$count = 1;
		while ($texte =~ /<a class=l href="(.*?)">/i) {
			$the_url = $1;
			
			if ($the_url =~ /$test_url/i) {
				$calcul = $start + $count;
				
				print "<a href=\"http://www.google.fr/search?hl=fr&rls=GGGL%2CGGGL%3A2005-09%2CGGGL%3Afr&q=$motcle&btnG=Rechercher&meta=&num=100&start=$start$option\" target=\"_blank\" class=\"lien_noir\">Position = $calcul</a>\n";
				exit;
			}
			
			$texte =~ s:<a class=l href=".*?">::i;
			
			$count++;
		}
	}
}

print "Votre page n'a pas été trouvé. Elle doit certainement se trouver au delà des 300 résultats.\n";
