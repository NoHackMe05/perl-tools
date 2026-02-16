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
    $option = "&rf=1";
}

$start = 0;
$num = 10;

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
    $start = $num * $i + 1;
    
    $texte = `lynx -source -accept_all_cookies "http://search.live.com/results.aspx?q=$motcle&mkt=fr-fr&FORM=LVSP&go=Search&first=$start$option"`;

    $texte =~ s:\%3A:\::gi;
    $texte =~ s:\%2F:\/:gi;

    $texte =~ s:<li class="first">:<li>:gi;

    if ($texte =~ /$test_url/i) {
	$count = 1;

	while ($texte =~ /<li><h3><a href=\"([^\"]+)\"/i) {
	    $the_url = $1;

	    if ($the_url =~ /$test_url/i) {
		$calcul = $start + $count - 1;

		print "<a href=\"http://search.live.com/results.aspx?q=$motcle&mkt=fr-fr&FORM=LVSP&go=Search&first=$start$option\" target=\"_blank\" 
class=\"lien_noir\">Position = $calcul</a>\n";

		exit;
	    }

	    $texte =~ s:<li><h3><a href=\"[^\"]+\"::i;

	    $count++;
	}
    }
}

print "Votre page n'a pas &eacute;t&eacute; trouv&eacute;. Elle doit certainement se trouver au del&agrave; des 30 r&eacute;sultats.\n";
