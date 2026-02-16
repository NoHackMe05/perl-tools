#!/usr/bin/perl
#
#
#

use Encode;
use HTML::Entities ();

$path_document = shift(@ARGV);
$path_recherche = shift(@ARGV);
$path_portail = shift(@ARGV);
$path_livres = shift(@ARGV);
$path_rech_livres = shift(@ARGV);

$filename = shift(@ARGV);
open(THESAURUS,"> $filename");

$filename = shift(@ARGV);
open(LISTE_CAT,"> $filename");

$filename = shift(@ARGV);
open(LISTE_LIVRES,"> $filename");

$filename = shift(@ARGV);
open(LISTE_URL,"> $filename");

$test_document = 0;

while (<>) {
	if (/<page>/i) {
		$test_document = 1;
		$test_debut_text = 0;
		$contenu = '';
		$portail = '';
		$titre_ouvrage = '';
		$liste_ouvrage = '';
		next;
	} elsif (/<\/page>/i) {
		$test_document = 0;
		$test_debut_text = 0;

		if ($continue_process) {
			$contenu =~ s:^[\n\s]+::sgi;

			while ($contenu =~ s:(\{\{[^\}]+)\n:$1:sgi) {}
			$contenu =~ s:\{\{[^\}]+\}\}::sgi;
			$contenu =~ s:\{\{[^\}]+\n\}\}::sgi;

			$contenu =~ s:\&lt\;ref\&gt\;.*?\&lt\;\/ref\&gt\;::gi;
			$contenu =~ s:\&lt\;ref name=[^\\]+\&gt\;.*?\&lt\;\/ref\&gt\;::gi;

			$contenu =~ s:\{\{[^\}]+\&lt\;\/ref\&gt\;::gi;

			$contenu =~ s:\n\n+:__BR__:sgi;
			$contenu =~ s:\n(\s*[\:\*]):__NBR__$1:sgi;
			$contenu =~ s:\s*\n\s*: :sgi;
			$contenu =~ s:__BR__:\n\n:sgi;
			$contenu =~ s:__NBR__:\n:sgi;

			$contenu =~ s:\{\{[^\}]+\}\}::gi;
			while ($contenu =~ s:\{[^\}\n]+\}::gi) {}

			if (length($contenu) > 1000) {
				$contenu =~ s:^(.{500,1000})\n.*$:$1:sgi;
			}

			if (length($contenu) > 1000) {
				$contenu =~ s:^(.{500,1000})\..*$:$1:sgi;
			}

			$contenu =~ s:\n+$::sgi;

			if ($contenu) {
				open(DOCUMENT,"> $path_document/$rep/$fichier.txt");
				print DOCUMENT "<t>$titre</t>\n";
				print DOCUMENT "<d>$contenu</d>\n";
				if ($titre_ouvrage) {
					print DOCUMENT $titre_ouvrage;
				}
				if ($portail) {
					print DOCUMENT "<p>$portail</p>\n";
				}
	
				close(DOCUMENT);

				$titre = HTML::Entities::encode($titre);
				$titre =~ s:\&([a-z])[a-z]+\;:$1:gi;
				$titre = HTML::Entities::decode($titre);

				open(RECHERCHE,"> $path_recherche/$rep/$fichier.txt");
				print RECHERCHE "$titre\n";
				close(RECHERCHE);

				if ($portail) {
					if ($liste_ouvrage) {
						$liste_ouvrage =~ s:\|: :g;

						print LISTE_LIVRES "$portail\t$liste_ouvrage\n";
					}

					$portail =~ s:\|: :g;

					$portail = HTML::Entities::encode($portail);
					$portail =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$portail = HTML::Entities::decode($portail);

					open(PORTAIL,"> $path_portail/$rep/$fichier.txt");
					print PORTAIL "$portail\n";
					print PORTAIL "LETTRE$lettre\n";
					close(PORTAIL);
				}
			}
		}

		next;
	}

	if ($test_document) {
		if (/<title>(.*?)<\/title>/i) {
			$titre = $1;
			if ($titre =~ /\xC3/) {
				$titre = decode_utf8($titre);
			}
			if ($titre =~ /^Projet\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Fichier\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Aide\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Wikip.dia\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Portail\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^MediaWiki\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Mod.le\:/i) {
				$continue_process = 0;
			} elsif ($titre =~ /^Cat.gorie\:/i) {
				$continue_process = 0;
			} else {
				$continue_process = 1;
			}

			if ($continue_process) {
				$new_titre = $titre;
				$new_titre =~ s: :_:g;
				$new_titre =~ s:\?:\%3F:g;

				$rep = $titre;
				$rep = HTML::Entities::encode($rep);
				$rep =~ s:\&([a-z])[a-z]+\;:$1:gi;
				$rep = HTML::Entities::decode($rep);
				$rep =~ s:[^a-z]::gi;
				$rep =~ tr/A-Z/a-z/;
				$rep =~ s:^(...).*$:$1:gi;
	
				$lettre = $rep;
				$lettre =~ s:^(.).*?$:$1:i;
				$lettre =~ tr/a-z/A-Z/;

				$fichier = $titre;
				$fichier = HTML::Entities::encode($fichier);
				$fichier =~ s:\&([a-z])[a-z]+\;:$1:gi;
				$fichier = HTML::Entities::decode($fichier);
				$fichier =~ s:[^a-z0-9\_\-]:_:gi;
				$fichier =~ tr/A-Z/a-z/;

				if (length($rep) < 3) {
					$rep = 'aaa';
				}

				next;
			}
		}

		if ($continue_process) {
			$my_test = $_;
			while ($my_test =~ /(http\:\/\/[a-z0-9\.\-]+)[^a-z0-9\.\-]/i) {
				$new_url = $1;

				if ($new_titre) {
					print LISTE_URL "$new_titre\t$new_url\n";
				}

				$my_test =~ s:http\:\/\/[a-z0-9\.\-]+[^a-z0-9\.\-]::i;
			}

			$my_test = $_;
			while ($my_test =~ /\[\[([^\]\:]+)\|([^\]]+)\]\]/i) {
				$col1 = decode_utf8($1);
				$col2 = decode_utf8($2);

				print THESAURUS "$col1\t$col2\n";

				$my_test =~ s:\[\[[^\]]+\|[^\]]+\]\]::i;
			}

			$my_test = $_;
			$my_test =~ s:\{\{(.{1,20})\}\}:$1:g;
			while ($my_test =~ /\{\{Ouvrage\|([^\}]+)\}\}/i) {
				$ouvrage = $1;
				if ($ouvrage =~ /\xC3/) {
					$ouvrage = decode_utf8($ouvrage);
				}

				$ouvrage =~ s:\[\[([^\]]+)\|[^\]]+\]\]:<b>$1</b>:gi;
				$ouvrage =~ s:\[\[([^\]]+)\]\]:<b>$1</b>:gi;

				$titre_livre = '';
				if ($ouvrage =~ /\| *titre *= *([^\|]+) *\|/i) {
					$titre_livre = $1;
				}
				$auteur_livre = '';
				if ($ouvrage =~ /\| *auteurs? *= *([^\|]+) *\|/i) {
					$auteur_livre = $1;
				}
				$editeur_livre = '';
				if ($ouvrage =~ /\| *.diteurs? *= *([^\|]+) *\|/i) {
					$editeur_livre = $1;
				}
				$collection_livre = '';
				if ($ouvrage =~ /\| *collection *= *([^\|]+) *\|/i) {
					$collection_livre = $1;
				}
				$annee_livre = '';
				if ($ouvrage =~ /\| *ann.e *= *([^\|]+) *\|/i) {
					$annee_livre = $1;
				}
				$isbn_livre = '';
				if ($ouvrage =~ /\| *isbn *= *([^\|]+) *\|/i) {
					$isbn_livre = $1;
				}
				$presentation_livre = '';
				if ($ouvrage =~ /\| *pr.sentation en ligne *= *([^\|]+) *\|/i) {
					$presentation_livre = $1;
				}
				$lire_livre = '';
				if ($ouvrage =~ /\| *lire en ligne *= *([^\|]+) *\|/i) {
					$lire_livre = $1;
				}

				if ($titre_livre && $auteur_livre && $isbn_livre) {
					$titre_ouvrage .= "<auteur>".$titre_livre." (de ".$auteur_livre.") | $isbn_livre</auteur>\n";
					$liste_ouvrage .= $titre_livre."|";

					$rep_livre = $titre_livre;
					$rep_livre = HTML::Entities::encode($rep_livre);
					$rep_livre =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$rep_livre = HTML::Entities::decode($rep_livre);
					$rep_livre =~ s:[^a-z]::gi;
					$rep_livre =~ tr/A-Z/a-z/;
					$rep_livre =~ s:^(...).*$:$1:gi;

					$fichier_livre = $titre_livre;
					$fichier_livre = HTML::Entities::encode($fichier_livre);
					$fichier_livre =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$fichier_livre = HTML::Entities::decode($fichier_livre);
					$fichier_livre =~ s:[^a-z0-9\_\-]:_:gi;
					$fichier_livre =~ tr/A-Z/a-z/;

					if (length($rep_livre) < 3) {
						$rep_livre = 'aaa';
					}

					open(LIVRES,"> $path_livres/$rep_livre/$fichier_livre.txt");
					print LIVRES "<t>".$titre_livre."</t>\n";
					print LIVRES "<a>de $auteur_livre";
					if ($annee_livre) {
						print LIVRES ", $annee_livre";
					}
					if ($editeur_livre) {
						print LIVRES ", $editeur_livre";
					}
					print LIVRES "</a>\n";
					if ($collection_livre) {
						print LIVRES "<c>$collection_livre</c>\n";
					}
					if ($isbn_livre) {
						print LIVRES "<i>$isbn_livre</i>\n";
					}
					if ($presentation_livre) {
						print LIVRES "<p>$presentation_livre</p>\n";
					}
					if ($lire_livre) {
						print LIVRES "<l>$lire_livre</l>\n";
					}
					close(LIVRES);

					$titre_livre = HTML::Entities::encode($titre_livre);
					$titre_livre =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$titre_livre = HTML::Entities::decode($titre_livre);

					$auteur_livre = HTML::Entities::encode($auteur_livre);
					$auteur_livre =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$auteur_livre = HTML::Entities::decode($auteur_livre);

					$editeur_livre = HTML::Entities::encode($editeur_livre);
					$editeur_livre =~ s:\&([a-z])[a-z]+\;:$1:gi;
					$editeur_livre = HTML::Entities::decode($editeur_livre);

					open(RECH_LIVRES,"> $path_rech_livres/$rep_livre/$fichier_livre.txt");
					print RECH_LIVRES "$titre_livre\n";
					print RECH_LIVRES "$auteur_livre\n";
					if ($editeur_livre) {
						print RECH_LIVRES "$editeur_livre\n";
					}
					print RECH_LIVRES "$isbn_livre\n";
					close(RECH_LIVRES);
				}
	
				$my_test =~ s:\{\{Ouvrage\|[^\}]+\}\}::i;
			}

			if (/\{\{Portail[\| ]([^\}]+)\}\}/i) {
				$portail = $1;
				if ($portail =~ /\xC3/) {
					$portail = decode_utf8($portail);
				}

				$tmp = $portail;
				$tmp =~ s:\s*\|\s*:\n:g;

				print LISTE_CAT "$tmp\n";
			}
	
			s:\{\{er\}\}:<sup>er</sup>:gi;
			s:\{\{Date\|([^\|]+)\|([^\|]+)\|([^\}]+)\}\}:<b>$1 $2 $3</b>:gi;

			$texte = '';
			if (/<text xml:space=\"preserve\">(.*)$/i) {
				$texte = $1;
				if ($texte =~ /\xC3/) {
					$texte = decode_utf8($texte);
				}
				$test_debut_text = 1;
	
				if ($texte =~ /\#redirect[^\n]*\[\[([^\]]+)\]\]/i) {
					print THESAURUS "$titre\t$1\n";
					$texte = '';
				} elsif ($texte =~ /^ *\{\{[^\}]+\n*$/i) {
					$test_debut_text = 0;
					$test_info_box = 1;
					$texte = '';
				}
			} elsif (/^==/i) {
				$test_debut_text = 0;
				$test_info_box = 0;
			} elsif (/<\/text>/i) {
				$test_debut_text = 0;
				$test_info_box = 0;
			} elsif (/^ *\{\{[^\}]+\n*$/i) {
				$test_debut_text = 0;
				$test_info_box = 1;
			} elsif (/^\}\}\&lt\;\/ref\&gt\;/ && $test_info_box) {
				$test_debut_text = 0;
			} elsif (/^\}\}/ && $test_info_box) {
				$test_debut_text = 1;
				$test_info_box = 0;
			} elsif ($test_debut_text) {
				$texte = $_;
				if ($texte =~ /\xC3/) {
					$texte = decode_utf8($texte);
				}
			}

			if ($texte) {
				$texte =~ s:\{\{.bauche\|[^\}\n]+\}\}::gi;
				$texte =~ s:^\|[^\}]+\}\}::gi;
				$texte =~ s:^\|[^\}]+$::gi;
				$texte =~ s:\[\[Fichier\:[^\]]+\]\]::gi;
				$texte =~ s:\[\[File\:[^\]]+\]\]::gi;
				$texte =~ s:\[\[Image\:[^\]]+\]\]::gi;
				$texte =~ s:^Image\:.*$::gi;
				$texte =~ s:\{\{Ouvrage\|[^\}]+\}\}::gi;
				$texte =~ s:\{\{Ouvrage\|[^\}]+$::gi;
				$texte =~ s:\{\{lien web\|[^\}]+\}\}::gi;
				$texte =~ s:\{\{lien web\|[^\}]+$::gi;
				$texte =~ s:\'\'\'(.*?)\'\'\':<b>$1</b>:gi;
				$texte =~ s:\'\'(.*?)\'\':<i>$1</i>:gi;
	
				$texte =~ s:\[\[([^\]]+)\|[^\]]+\]\]:<b>$1</b>:gi;
				$texte =~ s:\[\[([^\]]+)\]\]:<b>$1</b>:gi;

				$texte =~ s:\{\{[^\}]+\}\}::gi;
	
				$texte =~ s:\&lt\;ref\&gt\;.*?\&lt\;\/ref\&gt\;::gi;
				$texte =~ s:^[\[\]]+\n*$::gi;

				$texte =~ s:^[^\[]+\]\]::gi;
				$texte =~ s:<\/revision>::gi;
	
				$contenu .= $texte;
			}
		}
	}
}

close (THESAURUS);
close (LISTE_CAT);
close (LISTE_LIVRES);
close (LISTE_URL);
