sub check_page_adresse {
        local ($content) = @_;

	$tmp = $content;
	$tmp =~ s:</?[biu]>::gi;
	$tmp =~ s:<br */? *>::gi;
	$tmp =~ s:[\n\r]+::g;
	$tmp = HTML::Entities::decode($tmp);
	$tmp =~ s:<img[^>]*>::gi;
	$tmp =~ s:[\t\xa0]+: :gi;

        if ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Mentions *l.gales[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Infos l.gales[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Informations l.gales[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Conditions *g.n.rales *de *vente[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *CGV *</i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Qui *sommes[ \-]*nous[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Infos .diteur[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *A *propos[ <]/i) {
                return $1;
	}

        return;
}

sub check_page_contact {
        local ($content) = @_;

	$tmp = $content;
	$tmp =~ s:</?[biu]>::gi;
	$tmp =~ s:<br */? *>::gi;
	$tmp =~ s:[\n\r]+::g;
	$tmp = HTML::Entities::decode($tmp);
	$tmp =~ s:<img[^>]*>::gi;
	$tmp =~ s:[\t\xa0]+: :gi;

        if ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Contact[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Contactez[ \-]*nous[ <]/i) {
                return $1;
        } elsif ($tmp =~ /<a [^>]*href=\"?([^> \"]+)\"?[^>]*> *Nous Contacter[ <]/i) {
                return $1;
	}

        return;
}

sub check_adresses {
	local ($url,$my_first_url) = @_;

	my $req2 = new HTTP::Request GET => "$url";
        my $res2 = $ua->request($req2);

        print STDERR "GET ";

	if ($res2->is_success) {
        	print STDERR "OK\n";

                # Debut de la recherche des adresses
		my $tmp = $res2->content;

		&check_adresse_incontent($tmp,$my_first_url);
        } else {
		print STDERR "ERROR\n";
	}
}

sub check_adresse_incontent {
	local ($tmp,$my_first_url) = @_;

	if ($tmp) {
		$tmp = HTML::Entities::decode($tmp);

		# PATCH BEFORE

		$tmp =~ s:>(Coordonn.es)</span>:$1<br>:gi;
		$tmp =~ s:>(Adresses)</strong>:Par courrier<br>:gi;
		$tmp =~ s:>(Adresses)</b>:Par courrier<br>:gi;

		# SUPPRESSION DES BALISES

		$tmp =~ s:</?[biu]>::gi;
		$tmp =~ s:<div[^>]*>::gi;
		$tmp =~ s:<span[^>]*>::gi;
		$tmp =~ s:<font[^>]*>::gi;
		$tmp =~ s:</div>::gi;
		$tmp =~ s:</span>::gi;
		$tmp =~ s:</font>::gi;
		$tmp =~ s:[\r\n]+::g;
		$tmp =~ s:[\t\xa0]+: :g;
		$tmp =~ s:  +: :g;
		$tmp =~ s:<br[ \/]+>:<br>:gi;
		$tmp =~ s:<h[1-6][^>]*>::gi;
		$tmp =~ s:</h[1-6]>:<br>:gi;
		$tmp =~ s:<p[^>]*>::gi;
		$tmp =~ s:</p>:<br>:gi;
		$tmp =~ s:<br> *<br>:<br>:gi;
		$tmp =~ s:<li[^>]*>::gi;
		$tmp =~ s:<ul[^>]*>::gi;
		$tmp =~ s:<\/li>::gi;
		$tmp =~ s:<\/ul>::gi;
		$tmp =~ s:<\/?strong>::gi;
		$tmp =~ s:<img[^>]*>::gi;
		$tmp =~ s:<a [^>]+>::gi;
		$tmp =~ s:<\/a>::gi;

		# PATCH DE COMPATIBILITE
		$tmp =~ s:Nous .crire *\: *<br>:Par courrier \:<br>:gi;
		$tmp =~ s:<br> *FR *<br>:<br>:gi;

		$tmp = &check_telephone($tmp);
		$tmp = &check_fax($tmp);
		$tmp = &check_portable($tmp);
		$tmp = &check_email($tmp);

		$tmp = &check_code_postal_ville($tmp);
		$tmp = &check_adresse($tmp);
		$tmp = &check_nom($tmp);

		@tab = split(/(<type>[^<]+<\/type>)/,$tmp,1000);

		$fontion = '';

		while ($#tab >= 0) {
			$ligne = shift(@tab);

			$nom = '';
			$adresse = '';
			$code_postal = '';
			$ville = '';
			$telephone = '';
			$fax = '';
			$portable = '';
			$email = '';

			$ligne =~ s:<br>:__br__:gi;

			if ($ligne =~ /<type>([^<]+)<\/type>/i) {
				$fonction = $1;
				$fonction = &clean_chaine($fonction);
			}
			if ($ligne =~ /<nom>([^<]+)<\/nom>/i) {
				$nom = $1;
				$nom = &clean_chaine($nom);
			}
			if ($ligne =~ /<adresse>([^<]+)<\/adresse>/i) {
				$adresse = $1;
				$adresse = &clean_chaine($adresse);
			}
			if ($ligne =~ /<code_postal>([^<]+)<\/code_postal>/i) {
				$code_postal = $1;
				$code_postal = &clean_chaine($code_postal);
			}
			if ($ligne =~ /<ville>([^<]+)<\/ville>/i) {
				$ville = $1;
				$ville = &clean_chaine($ville);
			}
			if ($ligne =~ /<telephone>([^<]+)<\/telephone>/i) {
				$telephone = $1;
				$telephone = &clean_chaine($telephone);
			}
			if ($ligne =~ /<fax>([^<]+)<\/fax>/i) {
				$fax = $1;
				$fax = &clean_chaine($fax);
			}
			if ($ligne =~ /<portable>([^<]+)<\/portable>/i) {
				$portable = $1;
				$portable = &clean_chaine($portable);
			}
			if ($ligne =~ /<email>([^<]+)<\/email>/i) {
				$email = $1;
				$email = &clean_chaine($email);
			}

			if (($nom ne '') && ($adresse ne '') && ($code_postal ne '') && ($ville ne '')) {
				if ($fonction eq '') {
					$fonction = 'indefini';
				}

				$tera_url = $config_url_language{$select_language} . "ajout_info_societe.php?cle=DeTeCtIvE&url=$my_first_url&nom=$nom&adresse=$adresse&code_postal=$code_postal&ville=$ville&telephone=$telephone&fax=$fax&portable=$portable&email=$email&fonction=$fonction&lang=".$select_language;
				my $req3 = new HTTP::Request GET => "$tera_url";
				my $res3 = $ua->request($req3);
			} elsif (($ligne !~ /<type>/i) && ($fonction ne '')) {
				print STDERR "Infos manquantes : fonction=$fonction, nom=$nom, adresse=$adresse, code postal=$code_postal, ville=$ville\n";
			}
		}
        }
}

sub clean_chaine {
	local ($tmp) = @_;

	$tmp =~ s:^[ \-,;\?\!\.]+::gi;
	$tmp =~ s:[ \-,;\?\!\.]+$::gi;

	$tmp =~ s:__br__:<br>:gi;

	return $tmp;
}

sub check_nom {
	local ($tmp) = @_;

	$tmp =~ s: *\( *:<br>:gi;
	$tmp =~ s: *\) *:<br>:gi;

	# PROPRIETE
	$tmp =~ s:Le pr.sent site est la propri.t. de ([^<,]+) *, Soci.t. :<type>propriete</type><nom>$1</nom>:gi;
	$tmp =~ s:Le pr.sent site est la propri.t. de ([^<,]+) *, dont le si.ge  :<type>propriete</type><nom>$1</nom>:gi;
	$tmp =~ s:Le pr.sent site est la propri.t. de ([^<]+) au capital:<type>propriete</type><nom>$1</nom>:gi;

	# COORDONNEES
	$tmp =~ s:Coordonn.es *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>coordonnees</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Coordonn.es *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>coordonnees</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Coordonn.es *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>coordonnees</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:Coordonn.es *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>coordonnees</type><nom>$1</nom><adresse>:gi;

	# COURRIER
	$tmp =~ s:Par +courrier[^<]* *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>courrier</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Par +courrier[^<]* *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>courrier</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Par +courrier[^<]* *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>courrier</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:Par +courrier[^<]* *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>courrier</type><nom>$1</nom><adresse>:gi;

	# INDEFINI
	$tmp =~ s:D.nomination sociale *\:? +([^,><]{1,50}) *<br>:<type>indefini</type><nom>$1</nom>:gi;
	$tmp =~ s:par +la +soci.t. *<br>([^><]{1,50})<br> *<adresse>:<type>indefini</type><nom>$1</nom><adresse>:gi;
	$tmp =~ s:par +la +soci.t. *<br>([^><]{1,50}) *\- *<adresse>:<type>indefini</type><nom>$1</nom><adresse>:gi;
	$tmp =~ s:<td[^>]*>([^><]{1,50}) *\- *<adresse>:<type>indefini</type><nom>$1</nom><adresse>:gi;
	$tmp =~ s:<td[^>]*>([^><]{1,50}) *<br> *<adresse>:<type>indefini</type><nom>$1</nom><adresse>:gi;

	# SIEGE SOCIAL
	$tmp =~ s:Si.ge sociale? *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>siege_social</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Si.ge sociale? *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>siege_social</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Si.ge sociale? *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>siege_social</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:Si.ge sociale? *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>siege_social</type><nom>$1</nom><adresse>:gi;

	# EDITEUR
	$tmp =~ s:Editeur *\: +([^,><]{1,50}) *<br>:<type>editeur</type><nom>$1</nom>:gi;
	$tmp =~ s:Editeur *[\:\-]? +([^,><]{1,50}) *<br> *<adresse>:<type>editeur</type><nom>$1</nom><adresse>:gi;
	$tmp =~ s: .dit. +par +la +soci.t. +([^,><]{1,50}), +SA:<type>editeur</type><nom>$1</nom>, SA:gi;
	$tmp =~ s:.diteur *<br> *([^,><]{1,50}), :<type>editeur</type><nom>$1</nom>:gi;
	$tmp =~ s:.diteur *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>editeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:.diteur *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>editeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:.diteur *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>editeur</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:.diteur *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>editeur</type><nom>$1</nom><adresse>:gi;

	# HEBERGEUR
	$tmp =~ s: h.berg. +par +([^,><]{1,50}), :<type>hebergeur</type><nom>$1</nom>:gi;

	$tmp =~ s:H.bergeur *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>hebergeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:H.bergeur *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>hebergeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:H.bergeur *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>hebergeur</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:H.bergeur *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>hebergeur</type><nom>$1</nom><adresse>:gi;

	$tmp =~ s:Prestataires +d.h.bergements *\:? *<br>([^><]{1,50})<br>([^><]+<br>[^><]+)<br> *<code_postal>:<type>hebergeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Prestataires +d.h.bergements *\:? *<br>([^><]{1,50})<br>([^><]+)<br> *<code_postal>:<type>hebergeur</type><nom>$1</nom><adresse>$2</adresse><code_postal>:gi;
	$tmp =~ s:Prestataires +d.h.bergements *\:? *<br>([^><]{1,50})<br>([^><]+<br>) *<adresse>:<type>hebergeur</type><nom>$1</nom><adresse>$2:gi;
	$tmp =~ s:Prestataires +d.h.bergements *\:? *<br>([^><]{1,50})<br> *<adresse>:<type>hebergeur</type><nom>$1</nom><adresse>:gi;

	$tmp =~ s:H.bergement *\:? *([^><]{1,50}) *[\-,] <adresse>:<type>hebergeur</type><nom>$1</nom><adresse>:gi;

	return $tmp;
}

sub check_adresse {
	local ($tmp) = @_;

	$tmp =~ s:([ >\-\,\:][0-9]+ *[bis]* *,?) av :$1 avenue :gi;
	$tmp =~ s:([ >\-\,\:][0-9]+ *[bis]* *,?) r :$1 rue :gi;
	$tmp =~ s:([ >\-\,\:][0-9]+ *[bis]* *,?) bd :$1 boulevard :gi;
	$tmp =~ s:([ >\-\,\:][0-9]+ *[bis]* *,?) pl :$1 place :gi;
	$tmp =~ s:([ >\-\,\:][0-9]+ *[bis]* *,?) rte :$1 route :gi;

	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? avenue [^<]+ *<br> *B\.P\. +[0-9]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? rue [^<]+ *<br> *B\.P\. +[0-9]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? boulevard [^<]+ *<br> *B\.P\. +[0-9]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? place [^<]+ *<br> *B\.P\. +[0-9]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? route [^<]+ *<br> *B\.P\. +[0-9]+)( *<br>):$1<adresse>$2</adresse>$3:gi;

	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? avenue [^<]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? rue [^<]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? boulevard [^<]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? place [^<]+)( *<br>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? route [^<]+)( *<br>):$1<adresse>$2</adresse>$3:gi;

	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? avenue [^<]+ *<br> *B\.P\. +[0-9]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? rue [^<]+ *<br> *B\.P\. +[0-9]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? boulevard [^<]+ *<br> *B\.P\. +[0-9]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? place [^<]+ *<br> *B\.P\. +[0-9]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;

	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? avenue [^<]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? rue [^<]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? boulevard [^<]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]+ *[bis]* *,? place [^<]+)( *<code_postal>):$1<adresse>$2</adresse>$3:gi;

	$tmp =~ s:( +\- +)(B\.?P\.? +[0-9]+) +\- +(<code_postal>):$1<adresse>$2</adresse>$3:gi;

	return $tmp;
}

sub check_code_postal_ville {
	local ($tmp) = @_;

	$tmp =~ s:([ >\-\,\:])([0-9]{5,5}) +([^<]+)( *<br>):$1<code_postal>$2</code_postal><ville>$3</ville>$4:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]{5,5}) +([^<\-]+)( \-):$1<code_postal>$2</code_postal><ville>$3</ville>$4:gi;
	$tmp =~ s:([ >\-\,\:])([0-9]{5,5}) +([^<\.]+)( *\.):$1<code_postal>$2</code_postal><ville>$3</ville>$4:gi;

	return $tmp;
}

sub check_telephone {
	local ($tmp) = @_;

	$tmp =~ s:([ >]t.l\.? *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<telephone>$2</telephone>$3:gi;
	$tmp =~ s:([ >]t.l\.? *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<telephone>$2</telephone>$3:gi;

	$tmp =~ s:([ >]t.l.phone *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<telephone>$2</telephone>$3:gi;
	$tmp =~ s:([ >]t.l.phone *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<telephone>$2</telephone>$3:gi;

	return $tmp;
}

sub check_fax {
	local ($tmp) = @_;

	$tmp =~ s:([ >]fax *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<fax>$2</fax>$3:gi;
	$tmp =~ s:([ >]fax *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<fax>$2</fax>$3:gi;

	$tmp =~ s:([ >]t.l.copie *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<fax>$2</fax>$3:gi;
	$tmp =~ s:([ >]t.l.copie *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<fax>$2</fax>$3:gi;

	return $tmp;
}

sub check_portable {
	local ($tmp) = @_;

	$tmp =~ s:([ >]mobile *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<portable>$2</portable>$3:gi;
	$tmp =~ s:([ >]mobile *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<portable>$2</portable>$3:gi;

	$tmp =~ s:([ >]portable *[\:\-\/\|]? +)([0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<portable>$2</portable>$3:gi;
	$tmp =~ s:([ >]portable *[\:\-\/\|]? +)(\+[0-9]{2,3} +\([0-9]\)[0-9] +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2} +[0-9]{2,2})([ <\-]):$1<portable>$2</portable>$3:gi;

	return $tmp;
}

sub check_email {
	local ($tmp) = @_;

	$tmp =~ s:([ >]Mail *[\:\-\/\|]? +)([a-z\-\_\.0-9]+\@[a-z\-\_\.0-9]+\.[a-z]+)([ <\-]):$1<email>$2</email>$3:gi;
	$tmp =~ s:([ >]Email *[\:\-\/\|]? +)([a-z\-\_\.0-9]+\@[a-z\-\_\.0-9]+\.[a-z]+)([ <\-]):$1<email>$2</email>$3:gi;
	$tmp =~ s:([ >]E\-mail *[\:\-\/\|]? +)([a-z\-\_\.0-9]+\@[a-z\-\_\.0-9]+\.[a-z]+)([ <\-]):$1<email>$2</email>$3:gi;

	return $tmp;
}

1;

