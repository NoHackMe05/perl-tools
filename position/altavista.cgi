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
    $option = "&kgs=1";
} else {
    $option = "&kgs=0";
}

$start = 0;
$num = 10;

$test_url = $url;
$test_url =~ tr/A-Z/a-z/;
$test_url =~ s: +::g;
$test_url =~ s:http\://::gi;
$test_url =~ s:\/::g;
$test_url =~ s:\:::g;
$test_url =~ s:\.:\\\.:g;

print "Content-type: text/plain\n\n";

for ($i=0; $i<3; $i++) {
    $start = $num * $i + 1;
    $page = $num * $i;
    
    $texte = `lynx -source -accept_all_cookies "http://fr.altavista.com/web/results?itag=ody&q=$motcle&kls=0&stq=$page$option"`;

    $texte =~ s:\%3A:\::gi;
    $texte =~ s:\%2F:\/:gi;

    if ($texte =~ /$test_url/i) {
	$count = 1;

	while ($texte =~ /<span class=\"?ngrn\"?> *([^ ]+) *<\/span>/i) {
	    $the_url = $1;

	    if ($the_url =~ /$test_url/i) {
		$calcul = $start + $count - 1;

		print "<a href=\"http://fr.altavista.com/web/results?itag=ody&q=$motcle&kls=0&stq=$page$option\" target=\"_blank\" class=\"lien_noir\">Position = $calcul</a>\n";

		exit;
	    }

	    $texte =~ s:<span class=\"?ngrn\"?> *[^ ]+ *</span>::i;

	    $count++;
	}
    }
}

print "Votre page n'a pas &eacute;t&eacute; trouv&eacute;. Elle doit certainement se trouver au del&agrave; des 30 r&eacute;sultats.\n";
