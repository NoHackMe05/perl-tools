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
    $option = "&dm=ctry";
} else {
    $option = "&dm=all";
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
    $page = $i + 1;
    
    $texte = `lynx -source -accept_all_cookies "http://fr.ask.com/web?q=$motcle&qsrc=0&o=312&page=$page$option"`;

    $texte =~ s:\%3A:\::gi;
    $texte =~ s:\%2F:\/:gi;

    $texte =~ s:\r::g;

    if ($texte =~ /$test_url/i) {
	$count = 1;

	while ($texte =~ /<a id=\"r[0-9]+_t\" class=\"L4\" href="(.*?)"/i) {
	    $the_url = $1;

	    if ($the_url =~ /$test_url/i) {
		$calcul = $start + $count - 1;

		print "<a href=\"http://fr.ask.com/web?q=$motcle&qsrc=0&o=312&page=$page$option\" target=\"_blank\" class=\"lien_noir\">Position = $calcul</a>\n";

		exit;
	    }

	    $texte =~ s:<a id="r[0-9]+_t" class="L4" href=".*?"::i;

	    $count++;
	}
    }
}

print "Votre page n'a pas &eacute;t&eacute; trouv&eacute;. Elle doit certainement se trouver au del&agrave; des 30 r&eacute;sultats.\n";
