sub check_country {
	local ($url,$max_count_tentative,$count_tentative) = @_;

	my $url_lite = $url;
	$url_lite =~ s:^https?\:?/?/?::i;

	if (($url =~ /\.fr\/?$/i) || ($url =~ /\.tf\/?$/i) || ($url =~ /\.gf\/?$/i) || ($url =~ /\.pf\/?$/i) || ($url =~ /\.re\/?$/i) || ($url =~ 
/\.gp\/?$/i)) {
		return 'fr';
	} elsif (($url_lite =~ /^fr\./i) || ($url =~ /^tf\./i) || ($url =~ /^gf\./i) || ($url =~ /^pf\./i) || ($url =~ /^re\./i) || ($url =~ /^gp\./i)) 
{
		return 'fr';
	} elsif ($url =~ /\.be\/?$/i) {
		return 'be';
	} elsif ($url_lite =~ /^be\./i) {
		return 'be';
	} elsif ($url =~ /\.es\/?$/i) {
		return 'es';
	} elsif ($url_lite =~ /^es\./i) {
		return 'es';
	} elsif ($url =~ /\.it\/?$/i) {
		return 'it';
	} elsif ($url_lite =~ /^it\./i) {
		return 'it';
	} elsif ($url =~ /\.de\/?$/i) {
		return 'de';
	} elsif ($url_lite =~ /^de\./i) {
		return 'de';
	} elsif ($url =~ /\.uk\/?$/i) {
		return 'uk';
	} elsif ($url_lite =~ /^uk\./i) {
		return 'uk';
	} elsif ($url =~ /\.at\/?$/i) {
		return 'at';
	} elsif ($url_lite =~ /^at\./i) {
		return 'at';
	} elsif ($url =~ /\.fi\/?$/i) {
		return 'fi';
	} elsif ($url_lite =~ /^fi\./i) {
		return 'fi';
	} elsif ($url =~ /\.lu\/?$/i) {
		return 'lu';
	} elsif ($url_lite =~ /^lu\./i) {
		return 'lu';
	} elsif ($url =~ /\.no\/?$/i) {
		return 'no';
	} elsif ($url_lite =~ /^no\./i) {
		return 'no';
	} elsif ($url =~ /\.nl\/?$/i) {
		return 'nl';
	} elsif ($url_lite =~ /^nl\./i) {
		return 'nl';
	} elsif ($url =~ /\.pt\/?$/i) {
		return 'pt';
	} elsif ($url_lite =~ /^pt\./i) {
		return 'pt';
	} elsif ($url =~ /\.se\/?$/i) {
		return 'se';
	} elsif ($url_lite =~ /^se\./i) {
		return 'se';
	} elsif ($url =~ /\.ch\/?$/i) {
		return 'ch';
	} elsif ($url_lite =~ /^ch\./i) {
		return 'ch';
#	} elsif ($url =~ /\.eu\/?$/i) {
#		return 'eu';
#	} elsif ($url_lite =~ /^eu\./i) {
#		return 'eu';
	} else {
		my $check_domain = $url;
		$check_domain =~ s:^https?\:?/?/?::i;
		$check_domain =~ s:\/$::;

		my ($country,$country_name) = LookUp($check_domain);

		if (($country =~ /^FR$/i) || ($country =~ /^TF$/i) || ($country =~ /^GF$/i) || ($country =~ /^PF$/i) || ($country =~ /^RE$/i) || 
($country =~ /^GP$/i)) {
			return 'fr';
		} elsif ($country =~ /^BE$/i) {
			return 'be';
		} elsif ($country =~ /^ES$/i) {
			return 'es';
		} elsif ($country =~ /^IT$/i) {
			return 'it';
		} elsif ($country =~ /^DE$/i) {
			return 'de';
		} elsif ($country =~ /^GB$/i) {
			return 'uk';
		} elsif ($country =~ /^AT$/i) {
			return 'at';
		} elsif ($country =~ /^FI$/i) {
			return 'fi';
		} elsif ($country =~ /^LU$/i) {
			return 'lu';
		} elsif ($country =~ /^NO$/i) {
			return 'no';
		} elsif ($country =~ /^NL$/i) {
			return 'nl';
		} elsif ($country =~ /^PT$/i) {
			return 'pt';
		} elsif ($country =~ /^SE$/i) {
			return 'se';
		} elsif ($country =~ /^CH$/i) {
			return 'ch';
		}

		my $check_domain = $url;
		$check_domain =~ s:^https?\:?/?/?::i;
		$check_domain =~ s:^www\.::i;
		$check_domain =~ s:^.*\.([^\.]{4,250}\.):$1:;
		$check_domain =~ s:\/$::;

		if ($count_tentative[1] < $max_count_tentative) {
			my $ext = $url;
			$ext =~ s:^.*\.([a-z]+)[ \xa0\t\n/]*$:$1:i;
			$ext =~ tr/A-Z/a-z/;
			
			my $res4 = &whois($check_domain,$SERVEUR{$ext});

			$count_tentative[1]++;

			if (($res4 =~ /[ \xa0\t\n\r\:\;]FR[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]FRANCE[ \xa0\t\n\r]/i)) {
				return 'fr';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]BE[\n\r]/) || ($res4 =~ /\.BE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]BELGIUM[ \xa0\t\n\r]/i)) {
				return 'be';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]ES[\n\r]/) || ($res4 =~ /\.ES[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]ESPA.A[ \xa0\t\n\r]/i)) {
				return 'es';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]IT[\n\r]/) || ($res4 =~ /\.IT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]ITALIA[ \xa0\t\n\r]/i)) {
				return 'it';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]DE[\n\r]/) || ($res4 =~ /\.DE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]DEUTSCHLAND[ \xa0\t\n\r]/i)) {
				return 'de';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]UK[\n\r]/) || ($res4 =~ /\.UK[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]UNITED KINGDOM[ \xa0\t\n\r]/i)) {
				return 'uk';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]AT[\n\r]/) || ($res4 =~ /\.AT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]AUSTRIA[ \xa0\t\n\r]/i)) {
				return 'at';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]FI[\n\r]/) || ($res4 =~ /\.FI[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]FINLAND[ \xa0\t\n\r]/i)) {
				return 'fi';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]LU[\n\r]/) || ($res4 =~ /\.LU[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]LUXEMBOURG[ \xa0\t\n\r]/i)) {
				return 'lu';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]NO[\n\r]/) || ($res4 =~ /\.NO[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]NORVEGE[ \xa0\t\n\r]/i)) {
				return 'no';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]NL[\n\r]/) || ($res4 =~ /\.NL[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]NETHERLANDS[ \xa0\t\n\r]/i)) {
				return 'nl';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]PT[\n\r]/) || ($res4 =~ /\.PT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]PORTUGAL[ \xa0\t\n\r]/i)) {
				return 'pt';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]SE[\n\r]/) || ($res4 =~ /\.SE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]SWEDEN[ \xa0\t\n\r]/i)) {
				return 'se';
			} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]CH[\n\r]/) || ($res4 =~ /\.CH[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]SWITZERLAND[ \xa0\t\n\r]/i)) {
				return 'ch';
			}
		}

		if ($count_tentative[1] >= $max_count_tentative) {
			if ($count_tentative[2] < $max_count_tentative) {
				my $res4 = `whois $check_domain`;
				
				$count_tentative[2]++;

				if (($res4 =~ /[ \xa0\t\n\r\:\;]FR[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]FRANCE[ \xa0\t\n\r]/i)) {
					return 'fr';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]BE[\n\r]/) || ($res4 =~ /\.BE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]BELGIUM[ \xa0\t\n\r]/i)) {
					return 'be';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]ES[\n\r]/) || ($res4 =~ /\.ES[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]ESPA.A[ \xa0\t\n\r]/i)) {
					return 'es';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]IT[\n\r]/) || ($res4 =~ /\.IT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]ITALIA[ \xa0\t\n\r]/i)) {
					return 'it';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]DE[\n\r]/) || ($res4 =~ /\.DE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]DEUTSCHLAND[ \xa0\t\n\r]/i)) {
					return 'de';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]UK[\n\r]/) || ($res4 =~ /\.UK[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]UNITED KINGDOM[ \xa0\t\n\r]/i)) {
					return 'uk';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]AT[\n\r]/) || ($res4 =~ /\.AT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]AUSTRIA[ \xa0\t\n\r]/i)) {
					return 'at';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]FI[\n\r]/) || ($res4 =~ /\.FI[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]FINLAND[ \xa0\t\n\r]/i)) {
					return 'fi';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]LU[\n\r]/) || ($res4 =~ /\.LU[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]LUXEMBOURG[ \xa0\t\n\r]/i)) {
					return 'lu';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]NO[\n\r]/) || ($res4 =~ /\.NO[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]NORVEGE[ \xa0\t\n\r]/i)) {
					return 'no';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]NL[\n\r]/) || ($res4 =~ /\.NL[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]NETHERLANDS[ \xa0\t\n\r]/i)) {
					return 'nl';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]PT[\n\r]/) || ($res4 =~ /\.PT[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]PORTUGAL[ \xa0\t\n\r]/i)) {
					return 'pt';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]SE[\n\r]/) || ($res4 =~ /\.SE[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]SWEDEN[ \xa0\t\n\r]/i)) {
					return 'se';
				} elsif (($res4 =~ /[ \xa0\t\n\r\:\;]CH[\n\r]/) || ($res4 =~ /\.CH[ \t\xa0\n\r]/) || ($res4 =~ /[ \xa0\t\n\r\:\;]SWITZERLAND[ \xa0\t\n\r]/i)) {
					return 'ch';
				}
			}
		}
	}

	return 0;
}

1;
