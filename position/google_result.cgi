#!/usr/bin/perl
#
#

use CGI;
use LWP;

my $mon_adresse_email = "paul.personne\@bl-dev.fr";

$query = new CGI;

$motcle = $query->param('motcle');

### PETIT DELAI DE QUELQUES SECONDES ###
my $wait = int(rand(3));
sleep($wait);

print "Content-type: text/plain\n\n";
print "Mot-cle\tPosition\tTitre\tLien\tDescription\tDomaine\n";

### CONFIGURATION DU BROWSER ###

my $browser = new LWP::UserAgent;

$browser->timeout(20);

my $request = new HTTP::Request( GET => "http://www.google.com/search?q=".urlEncode($motcle)."&hl=fr" );

### CONFIGURATION DU HEADER ###

my $headers = $request->headers();

$headers->header( 'User-Agent','Mozilla/5.0 (Windows NT 6.0; rv:5.0) Gecko/20100101 Firefox/5.0');

$headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');

#$headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');

$headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');

$headers->header( 'Accept-Language', 'fr, en');

$headers->header('Referer', 'www.google.com');

### CONFIGURATION DU PROXY ###

require "liste_proxy.ph";

my $total = $#LISTE_PROXY - 1;
my $indice = int(rand($total));

if ($LISTE_PROXY[$indice]) {
	$browser->proxy (['http'], 'http://'.$LISTE_PROXY[$indice]);
} else {
	#definitions
	my $MailPgm = '/usr/sbin/sendmail';
	my $Mail= $mon_adresse_email;
	my $From= $mon_adresse_email;
	my $Subject= "Google Result : Probl�me de configuration du proxy";
	my $Text= "";
	
	open (MAIL, "|$MailPgm $Mail") || die "Erreur sur $MailPgm!\n";
	print MAIL "From: $From\n";
	print MAIL "Reply-To: $From\n";
	print MAIL "To: $Mail\n";
	print MAIL "Subject: $Subject\n\n";
	print MAIL "$Text\n.";
	close MAIL;
}

### ENVOI DE LA REQUETE ###

my $response = $browser->request($request);

if ($response->is_success) {
	my $result = $response->content;

	$motcle =~ s:\t: :g;
	my $compteur = 1;

	if ($result) {
		while ($result =~ /<h3 class=\"r\">(.*?)<\/h3>/i) {
		        $titre = $1;
			$titre =~ s:<\/?b>::g;
			$titre =~ s:<\/?i>::g;
			$titre =~ s:<\/?em>::g;
			$titre =~ s:<br[ \/]*>::g;

		        if ($titre =~ /href=\"([^\"]+)\"/i) {
		                $lien = $1;

		                $domaine = $lien;
		                $domaine =~ s:^(https?\:\/\/[^\/]+)\/?.*$:$1\/:i;
		        }

		        $titre =~ s:<a [^>]+>::gi;
		        $titre =~ s:<\/a>::gi;

		        if ($result =~ /<span class=st>(.*?)<\/span>/i) {
		                $description = $1;
				$description =~ s:<\/?b>::g;
				$description =~ s:<\/?i>::g;
				$description =~ s:<\/?em>::g;
				$description =~ s:<br[ \/]*>::g;

		                $result =~ s:<span class=st>.*?<\/span>::i;
		        }

		        $result =~ s:<h3 class=\"r\">.*?</h3>::i;

			$titre =~ s:\t: :g;
			$lien =~ s:\t: :g;
			$description =~ s:\t: :g;
			$domaine =~ s:\t: :g;

		        print $motcle,"\t",$compteur,"\t",$titre,"\t",&new_encode_utf8($lien),"\t",$description,"\t",&new_encode_utf8($domaine),"\n";
			$compteur++;
		}
	} else {
		### ERREUR : liste vide ###

		#definitions
		my $MailPgm = '/usr/sbin/sendmail';
		my $Mail= $mon_adresse_email;
		my $From= $mon_adresse_email;
		my $Subject= "Google Result : Erreur dans la liste";
		my $Text= "La liste retourn�e est vide\n";
	
		open (MAIL, "|$MailPgm $Mail") || die "Erreur sur $MailPgm!\n";
		print MAIL "From: $From\n";
		print MAIL "Reply-To: $From\n";
		print MAIL "To: $Mail\n";
		print MAIL "Subject: $Subject\n\n";
		print MAIL "$Text\n.";
		close MAIL;
	}
} else {
	### ERREUR : pb de connexion au proxy ###

	#definitions
	my $MailPgm = '/usr/sbin/sendmail';
	my $Mail= $mon_adresse_email;
	my $From= $mon_adresse_email;
	my $Subject= "Google Result : Erreur de connexion";
	my $Text= "Erreur sur le proxy ".$LISTE_PROXY[$indice].":".$response->status_line."\n";

	open (MAIL, "|$MailPgm $Mail") || die "Erreur sur $MailPgm!\n";
	print MAIL "From: $From\n";
	print MAIL "Reply-To: $From\n";
	print MAIL "To: $Mail\n";
	print MAIL "Subject: $Subject\n\n";
	print MAIL "$Text\n.";
	close MAIL;
}

sub new_encode_utf8 {
	local($texte) = @_;

	$utf8string = $texte;	
	$utf8string =~ s:\&:\&amp\;:g;
	$utf8string =~ s:\':\&apos\;:g;
	$utf8string =~ s:\":\&quot\;:g;
	$utf8string =~ s:>:\&gt\;:g;
	$utf8string =~ s:<:\&lt\;:g;
						
	return $utf8string;
}

sub main::urlEncode {
	my ($string) = @_;
	$string =~ s/(\W)/"%" . unpack("H2", $1)/ge;
	#$string# =~ tr/.//;
	return $string;
}

