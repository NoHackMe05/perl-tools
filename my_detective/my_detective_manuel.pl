#!/usr/bin/perl
#
#

use LWP::Simple qw(get);
use WWW::RobotRules;
use LWP::UserAgent;
use URI::URL;
use HTTP::Date;
use HTML::Entities ();
use HTML::LinkExtor;
use HTML::Tagset;
use URI::_foreign;
#use Net::FTP;
use IO::Socket; 
use XML::RSS::Parser;
use Geo::IPfree qw(LookUp);
use MIME::Lite;

require "my_detective.cfg";
require "my_detective.lib";
require "serveur.ph";
require "country.ph";
require "boutique.ph";
require "info_compl.ph";

$test_maj = 0;
$test_pays = 1;

while( ($arg = shift(@ARGV)) ){
	if( $arg =~ /-url/ ) {
		$url = shift(@ARGV);
	} elsif( $arg =~ /-lang/ ) {
		$select_language = shift(@ARGV);
	} elsif( $arg =~ /-motcle/ ) {
		$add_keyword = shift(@ARGV);
	} elsif( $arg =~ /-limit/ ) {
		$nb_page_server = shift(@ARGV);
		$wait = 0;
	} elsif( $arg =~ /-is_maj/ ) {
		$test_maj = 1;
	} elsif( $arg =~ /-force/ ) {
		$test_pays = 0;
	} elsif( $arg =~ /-list/ ) {
		$listfile = shift(@ARGV);
	} elsif(( $arg =~ /-h/ ) || ( $arg =~ /-help/ )) {
		print "\nUsage: \n my_detective.pl -url URL OR -list listFILE\n";
		exit(1);
	} else {
		unshift(@ARGV, $arg);
		last;
	}
}

if (! defined($config_url_language{$select_language})) {
	print STDERR "Path not defined\n";
	exit;
}

@links = ();
%VISITED = ();
@count_tentative = ();
$count_tentative[1] = 0;
$count_tentative[2] = 0;
my $max_count_tentative = 6;

#	Robot definition
#
	$ua = new LWP::UserAgent $my_detective_version;
	$ua->agent($my_detective_version);
	$ua->from($my_detective_admin);
	$ua->timeout( $max_wait_time );

	$count = 0;
	$first = 0;
	$status = 0;
	if( $url ) {
		print STDERR "-----------\nStarting at URL: $url\n";
		print STDERR "Using BASE: $base\n" if($base);
		print STDERR "-----------\n";
		if( $url !~ /\.[^\/]{3,4}$/ && $url !~ /\/$/ ) {
			$url .= "/";
		}

		print "Check : $url\n";
			
		if ($url =~ /[\'\@\%]/) {
			print STDERR $url," skipped because character not good\n";

			$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			print STDERR "No URL for crawling...\n";
			print STDERR "Exit Spider\n";
			exit;
		} elsif (length($url) < 9) {
			print STDERR $url," skipped because small url\n";

			$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			print STDERR "No URL for crawling...\n";
			print STDERR "Exit Spider\n";
			exit;
		} elsif ($test_pays) {
			$test_country = &check_country($url,$max_count_tentative,\@count_tentative);

			if ($test_country ne $select_language) {
				if (defined($config_url_language{$test_country})) {
					$tera_url = $config_url_language{$test_country} . "ajout.php?cle=DeTeCtIvE&url=$url&lang=".$test_country;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					if ($res3->content =~ /^oui$/i) {
						print STDERR "Add ",$url," to database ",$test_country,"\n";
					} else {
						print STDERR $url," : already in database $test_country\n";
					}
				} else {
					print STDERR $url," skipped because not good site\n";
				}

				$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
				my $req3 = new HTTP::Request GET => "$tera_url";
				my $res3 = $ua->request($req3);

				$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
				my $req3 = new HTTP::Request GET => "$tera_url";
				my $res3 = $ua->request($req3);

				print STDERR "No URL for crawling...\n";
				print STDERR "Exit Spider\n";
				exit;
			}
		}

		push(@start_urls, $url);
	} elsif ($listfile) {
		print STDERR "-----------\nStarting with list file: $listfile";
		open( IN, "<$listfile" ) || die "Cannot open $listfile\n";
		while( <IN> ) {
			$nbline++;
			chop;
			if( !(/\.html?$/) && ! (/\/$/) ) {
				$_ .= "/";
			}
			push(@start_urls, $_);
		}
		close( IN );
		print STDERR " -- $nbline lines in files\n-----------\n";
		$url = $start_urls[0];
	} else {
		$test_country = 0;
								
		while ($test_country ne $select_language) {
			if (($count_tentative[1] >= $max_count_tentative) && ($count_tentative[2] >= $max_count_tentative)) {
				print STDERR "Max connexion du whois server...\n";
				print STDERR "Exit Spider\n";
				exit;			
			}

			if ($test_maj == '1') {
				$tera_url = $config_url_language{$select_language} . "new_site_maj.php?cle=DeTeCtIvE&lang=".$select_language;
			} else {
				$tera_url = $config_url_language{$select_language} . "new_site.php?cle=DeTeCtIvE&lang=".$select_language;
			}
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$url = $res3->content;
		
			print "Check : $url\n";
			
			if ($url) {
				if ($url =~ /[\'\@\%]/) {
					print STDERR $url," skipped because character not good\n";

					$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					$test_country = '';
				} elsif (length($url) < 9) {
					print STDERR $url," skipped because small url\n";

					$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					print STDERR "No URL for crawling...\n";
					print STDERR "Exit Spider\n";
					exit;
				} else {
					$test_country = &check_country($url,$max_count_tentative,\@count_tentative);

					if ($test_country ne $select_language) {
						if (defined($config_url_language{$test_country})) {
							$tera_url = $config_url_language{$test_country} . "ajout.php?cle=DeTeCtIvE&url=$url&lang=".$test_country;
							my $req3 = new HTTP::Request GET => "$tera_url";
							my $res3 = $ua->request($req3);

							if ($res3->content =~ /^oui$/i) {
								print STDERR "Add ",$url," to database ",$test_country,"\n";
							} else {
								print STDERR $url," : already in database $test_country\n";
							}
						} else {
							print STDERR $url," skipped because not good site\n";
						}

						$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
						my $req3 = new HTTP::Request GET => "$tera_url";
						my $res3 = $ua->request($req3);

						$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
						my $req3 = new HTTP::Request GET => "$tera_url";
						my $res3 = $ua->request($req3);
					}
				}
			} else {
				print STDERR "No URL for crawling...\n";
				print STDERR "Exit Spider\n";
				exit;
			}
		}

		print STDERR "-----------\nStarting with BDD: $url\n";
		push(@start_urls, $url);
	}
	
	if (! $url) {
		print STDERR "No URL for crawling...\n";
		print STDERR "Exit Spider\n";
		exit;
	}

	if ($url =~ /[^a-z0-9\:\/\/\-\_\.]/i) {
		$url =~ s:\\:\\\\:g;

		$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
		my $req3 = new HTTP::Request GET => "$tera_url";
		my $res3 = $ua->request($req3);

		$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
		my $req3 = new HTTP::Request GET => "$tera_url";
		my $res3 = $ua->request($req3);

		$test_country = '';

		print STDERR "Not good URL for crawling...\n";
		print STDERR "Exit Spider\n";
		exit;
	}
	if (($url !~ /^http\:\/\//i) || ($url =~ /^https\:\/\//i)) {
		$url =~ s:\\:\\\\:g;

		$tera_url = $config_url_language{$select_language} . "delete_test.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
		my $req3 = new HTTP::Request GET => "$tera_url";
		my $res3 = $ua->request($req3);

		$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
		my $req3 = new HTTP::Request GET => "$tera_url";
		my $res3 = $ua->request($req3);

		$test_country = '';

		print STDERR "Not good URL for crawling...\n";
		print STDERR "Exit Spider\n";
		exit;
	}

	$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
	my $req3 = new HTTP::Request GET => "$tera_url";
	my $res3 = $ua->request($req3);
	
	$count_tentative_1 = 0;
	$count_tentative_2 = 0;
	$max_count_tentative = 16;
	
	$my_first_url = $url;
	
	print STDERR "Allowed content-type: ",join(', ', @allowed_mime_type);
	print STDERR "\n----------------------\n";
	
	if( !$robot_url && $use_robot_url) {
		$roboturlobject = new URI::URL '/robots.txt';
		if( $base ) {
			$urlobject = new URI::URL $base;
		} else {
			$urlobject = new URI::URL $url;
		}
		$urlabs = $urlobject->abs;
		$roboturlobject = $roboturlobject->abs($urlabs);
		$robot_url = $roboturlobject->as_string;
	}
	if( $use_robot_url ) {
		$robotrules = new WWW::RobotRules $my_detective_version, $my_detective_admin;
		my $req_robot = get $robot_url;
		$robotrules->parse($robot_url,$req_robot);
	}
	
	while( $start_url = shift(@start_urls) ) {
		$base_hierarchy = ($start_url =~ tr/\//\//);
		$base_domain = $start_url;
		$base_domain =~ s:https?\://([^/]+)/.*:$1:i;
		$base_domain =~ tr/a-z/A-Z/;
		$base_email = $base_domain;
		$base_email =~ s:www\.::i;

		push(@links, $start_url); 
		while( ($link = shift(@links)) ) {
		        next if ($link =~ /\@/);

			$link_cap = $link;
			$link_cap =~ tr/a-z/A-Z/;
			if ($VISITED{$link_cap}==2) {
				next;
			}
			$VISITED{$link_cap} = 2;
	
			print STDERR "computing $link -->";
			
			$cur_domain = $link;
			$cur_domain =~ s:https?\://([^/]+)/.*:$1:i;
			$cur_domain =~ tr/a-z/A-Z/;
			if( grep(/$cur_domain/, @excluded_domain) ) {
				print STDERR " skipped because excluded domain\n";
				next;
			}
			if( $cur_domain ne $base_domain ) {
				$test_url = $link;
				$test_url =~ s:(https?\://[^/]+/).*:$1:i;
				$test_url .= "/" if ($test_url !~ /\/$/);

				$test_country = 0;

				$test_country = &check_country($test_url,$max_count_tentative,\@count_tentative);

				if (defined($config_url_language{$test_country})) {
					$tera_url = $config_url_language{$test_country} . "ajout.php?cle=DeTeCtIvE&url=$test_url&lang=".$test_country;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					if ($res3->content =~ /^oui$/i) {
						print STDERR "Found link ",$test_country,": ",$test_url,"\n";
					} else {
						print STDERR $test_url," : already in database $test_country\n";
					}
				} elsif (($count_tentative_1 >= $max_count_tentative) && ($count_tentative_2 >= $max_count_tentative)) {
					print STDERR $test_url," : max connexion whois server\n";
				} else {
					print STDERR " skipped because not good site\n";
				}
				
				next;
			}
			
			$cur_hierarchy = ($link =~ tr/\//\//);
			if( $cur_hierarchy < $base_hierarchy ) {
				print STDERR " skipped because above start url\n";
				next;
			}
			$tmplink = $link;
			$tmplink =~ s:/:\\/:g;
			$tmplink =~ s:\.:\\\.:g;
			$tmplink =~ s:\?:\\\?:g;
			$next_test = 0;
			if( grep(/$tmplink/, @excluded_url) ) {
				print STDERR " skipped because excluded\n";
				$next_test = 1;
			}
			for ($i=0;$i<=$#excluded_url_reg;$i++) {
				if ($tmplink =~ /$excluded_url_reg[$i]/i) {
					print STDERR " skipped because excluded (REG)\n";
					$next_test = 1;
				}
			}
			next if ($next_test);
			$content = &getURL($ua, $robotrules, $link, $base);
# BL 05/02/2004
			if( $content ) {
				&parseContent($content);
			}
		
#			print STDERR "\n";
			
#			@links = sort @links;
			
#			print STDERR "sleeping $wait seconds...\n";
			sleep($wait);
			
			if ($count > $nb_page_server) {
				print STDERR "Limit Nb Pages / Server...\n";
				print STDERR "Exit Spider\n";
				exit;
			}
			
			$count ++;
		}
	}

print STDERR "Exit Spider\n";
exit;

#Can't locate object method "host" via package "URI::mailto" at ../prog-bin/spider.pl line 473.
sub URI::mailto::host { return '' };

sub getURL {
	local( $ua, $robotrules, $url) = @_;
	local ($req, $res, $resline, $date);
	local (@mimetype, $type, $tmpfile);

	if ($robotrules && ! $robotrules->allowed($url)) {
	    if ($first == 0) {
		$status = '';
		if ($my_first_url ne $url) {
			$tera_url = $config_url_language{$select_language} . "update.php?cle=DeTeCtIvE&url=$my_first_url&check_url=$url&add_keyword=$add_keyword&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$status = $res3->content;
		} else {
#			$tera_url = $config_url_language{$select_language} . "update.php?cle=DeTeCtIvE&url=$my_first_url&add_keyword=$add_keyword&lang=".$select_language;
#			my $req3 = new HTTP::Request GET => "$tera_url";
#			my $res3 = $ua->request($req3);

#			$status = $res3->content;

			### PAS AUTORISE A ACCEDER AU SITE ###
			$tera_url = $config_url_language{$select_language} . "delete.php?cle=DeTeCtIvE&url=$my_first_url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$tera_url = $config_url_language{$select_language} . "delete_traitement.php?cle=DeTeCtIvE&url=$my_first_url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			print STDERR "Exit Spider\n";
			exit;
		}
		
		if ($status == 1) {
			$first = 1;
		}

		if ($status == 3) {
			print STDERR "Exit Spider\n";
			exit;
		}
	    }

	    print STDERR " URL DISALLOWED (Robot Rules)\n";
	    return "";
	}
	
	my $req = new HTTP::Request HEAD => "$url";
	for $type(@allowed_mime_type) {
		$req->push_header(Accept => $type);
	}

	my $res = $ua->request($req);
	
	if ($res->header('refresh') && $res->header('refresh') =~ /URL\s*=\s*(.+)/) {
		my $u = URI->new_abs( $res->header('location'),$url );
		if ($u !~ /^$/) {
			$url = $u;
			
			my $req = new HTTP::Request HEAD => "$url";
			for $type(@allowed_mime_type) {
				$req->push_header(Accept => $type);
			}
			
			my $res = $ua->request($req);
		}
	}

	if ($first == 0) {
		$status = '';
		if ($my_first_url ne $url) {
			$tera_url = $config_url_language{$select_language} . "update.php?cle=DeTeCtIvE&url=$my_first_url&check_url=$url&add_keyword=$add_keyword&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$status = $res3->content;
		} else {
			$tera_url = $config_url_language{$select_language} . "update.php?cle=DeTeCtIvE&url=$my_first_url&add_keyword=$add_keyword&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			$status = $res3->content;
		}
		
		if ($status == 1) {
			$first = 1;
		}

		if ($status == 3) {
			print STDERR "Exit Spider\n";
			exit;
		}

	}

	$date = $res->last_modified;
	$date = time2str($date);
	if ($res->is_success) {
		$type = $res->content_type;
		$type =~ s:/:\\/:g;
		$type =~ s:\.:\\\.:g;
		$type =~ s:\?:\\\?:g;
		$type =~ s:\+:\\\+:g;
		if( !grep(/$type/, @allowed_mime_type) ){

			print STDERR " URL OK , HEAD skipped because no good content-type\n";
			
			return "";
		}
		
		if ($type =~ /application\\\/pdf/i) {
			$tera_url = $config_url_language{$select_language} . "ajout_pdf.php?cle=DeTeCtIvE&url=$my_first_url&is_pdf=oui&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}

		if( grep(/$type/, @rss_mime_type) ){
#		    my $p = XML::RSS::Parser->new;
#		    my $feed = $p->parse_uri($url);

#		    if ($feed) {
#			my $feed_title = $feed->query('/channel/title');
#			my $rss_title = '';
#			if ($feed_title) {
#			    $rss_title = $feed_title->text_content;
#			}
#			my $feed_description = $feed->query('/channel/description');
#			my $rss_description = '';
#			if ($feed_description) {
#			    $rss_description = $feed_description->text_content;
#			}

			$tera_url = $config_url_language{$select_language} . "ajout_fichier.php?cle=DeTeCtIvE&extension=rss&title=&description=&links=".urlEncode($url)."&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			print STDERR " URL OK , RSS FILES\n";
#		    } else {
#			print STDERR " URL OK , RSS ERROR\n";
#		    }

		    return "";
		}

#		$tmpfile = "$root_path/tmp/tmpfile.$MIME_EXT{$res->content_type}";

		$tmpfile = $url;
		$tmpfile =~ s:https?\:\/\/::gi;
		$tmpfile =~ s:[^A-Z0-9]:_:gi;

		$tmpfile = "$root_path/tmp/".$tmpfile.".$MIME_EXT{$res->content_type}";
		
		print STDERR " URL OK , HEAD ";
		
		$resline = "<GABE_URL>$url</GABE_URL>\n";
		$resline .= "<GABE_TYPE>".$res->content_type."</GABE_TYPE>\n";
		$resline .= "<GABE_DATE>$date</GABE_DATE>\n";
		$resline .= "<GABE_STATE>OK</GABE_STATE>\n";
		my $req2 = new HTTP::Request GET => "$url";
		my $res2 = $ua->request($req2);

		print STDERR "GET ";
		
		if ($res2->is_success) {
			print STDERR "OK\n";

			open(OUT, ">$tmpfile") || die "Cannot open tmpfile\n";
			print OUT $res2->content;
			close OUT;
		} else {
			print STDERR "ERROR\n";
		}
	} else {
		print STDERR " URL ERROR HEAD\n";
		
		if ($url eq $my_first_url) {
			$tera_url = $config_url_language{$select_language} . "delete.php?cle=DeTeCtIvE&url=$url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}

		return "";
	}

	return $resline;
}

sub parseContent {
	local ($content,$base) = @_;
	local ($url, $urlabs, $link, $linkobject, $link_cap);
	local ($linkdomain, $domain_cap, $domain);
	local ($linktmp,$type,$tag,$oldlinktmp);
	local ($head, $title, $robotmeta, $language, $author, $date, $keywords, $description);
	local ($body, $textbody, $clean_body);
	local ($hasframe);
	local ($urlobject, $baseobject, $baseabs);

	$hasframe = 0;
	$content =~s:<GABE_URL>(.*?)</GABE_URL>\n::is;
	$url = $1;
	$content =~s:<GABE_DATE>(.*?)</GABE_DATE>\n::is;
	$date = $1;
	$content =~s:<GABE_TYPE>(.*?)</GABE_TYPE>\n::is;
	$type = $1;

	$content = &innerGet($type, $url);

	if( !$content ) {
		print STDERR "Unrecognized format: $type\n";
		return;
	}
	$content =~ s:\r\n:\n:g;
	if(  $content =~ /<HEAD[^>]*>/i ) {
		$content =~ s:<HEAD[^>]*>(.*?)</HEAD>::is;
		$head = $1;
		$head =~ s:\n: :g;
		$head =~ s: +: :g;
		if ($head =~ /META NAME="ROBOTS" CONTENT="(.*?)"/i && !$override_robotmeta) {
			$robotmeta = $1;
			if( $robotmeta =~ /NOINDEX/i ) {
				return;
			}
			if( $robotmeta =~ /NOFOLLOW/i ) {
				$tmpfollow = 0;
			}
		}
		if ($head =~ /META HTTP-EQUIV="?REFRESH"? [^>]+URL="?([^ >]+)"?/i) {
			$my_lien = $1;    
			$content =~ s:(<body[^>]*>):$1\n<a href="$my_lien"></a>:i;
		}
		while ($head =~ /<link rel=\"alternate\" type=\"application\/rss\+xml\"[^>]* href=\"([^\">]+)\"[ \/]*>/i) {
			$rss_links = $1;

			$link_cap = $rss_links;
			$link_cap =~ tr/a-z/A-Z/;
			if (! $VISITED{$link_cap}) {
				$tera_url = $config_url_language{$select_language} . "ajout_fichier.php?cle=DeTeCtIvE&extension=rss&title=&description=&links=".urlEncode($rss_links)."&url=".urlEncode($url)."&lang=".$select_language;
				my $req3 = new HTTP::Request GET => "$tera_url";
				my $res3 = $ua->request($req3);

				print STDERR $rss_links.": RSS FILE FIND\n";

				$VISITED{$link_cap} = 2;
			}

			$head =~ s:<link rel=\"alternate\" type=\"application\/rss\+xml\"[^>]* href=\"[^\">]+\"[ \/]*>::i;
		}
	} else {
		$head = "<TITLE>Document</TITLE>";
	}

#	print STDERR "Url : ",$url,"\n";

	$urlobject = new URI::URL $url;
	$urlabs = $urlobject->abs;
	$domain_cap = $urlobject->host;
	$domain_cap =~ tr/a-z/A-Z/;

	$domain = $urlabs;
	$domain =~ s:^(https?\://[^/]+/).*$:$1:i;

	if($head) {
		$check_email = $domain;
		$check_email =~ s:^https?\://::i;
		$check_email =~ s:\/ *$::i;
		$check_email =~ s:^www\.::i;
		if ($head =~ /([a-z\-\_\.0-9]+\@$check_email)/i) {
			$tera_url = $config_url_language{$select_language} . "ajout_email.php?cle=DeTeCtIvE&url=$my_first_url&email=$1&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}
	}

	if ($my_first_url eq $url) {
		# Recherche des adresses dans la homepage
		&check_adresse_incontent($content,$my_first_url);

		# Recherche page adresse
		$url_page_adresse = '';
		$url_page_adresse = &check_page_adresse($content);
		if ($url_page_adresse) {
			print STDERR "Page adresses trouvée ",$url_page_adresse," : ";

			if ($url_page_adresse !~ /^http/i) {
				$url_page_adresse =~ s:^\.\.?\/::;
				$url_page_adresse =~ s:^\/::;
				$url_page_adresse = $domain.$url_page_adresse;
			}

			&check_adresses($url_page_adresse,$my_first_url);
		}

		# Recherche page contact
		$url_page_contact = '';
		$url_page_contact = &check_page_contact($content);
		if ($url_page_contact) {
			print STDERR "Page Contact trouvée ",$url_page_contact," : ";

			if ($url_page_contact =~ /^mailto/i) {
				$url_page_contact = '';
			} elsif ($url_page_contact !~ /^http/i) {
				$url_page_contact =~ s:^\.\.?\/::;
				$url_page_contact =~ s:^\/::;
				$url_page_contact = $domain.$url_page_contact;
			}

			if ($url_page_contact) {
				&check_adresses($url_page_contact,$my_first_url);
			}
		}

		if ($url_page_adresse || $url_page_contact) {
			$url_page_adresse =~ s:[\?\&]PHPSESSID\=[a-z0-9]+\&:\&:i;
			$url_page_adresse =~ s:[\?\&]PHPSESSID\=[a-z0-9]+$:\&:i;
			$url_page_contact =~ s:[\?\&]PHPSESSID\=[a-z0-9]+\&:\&:i;
			$url_page_contact =~ s:[\?\&]PHPSESSID\=[a-z0-9]+$:\&:i;

			$tera_url = $config_url_language{$select_language} . "ajout_info_site.php?cle=DeTeCtIvE&url=$my_first_url&url_ml=$url_page_adresse&url_contact=$url_page_contact&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}
	}

	my $p = HTML::LinkExtor->new;
    	$p->parse( $content );

	for ( $p->links ) {
	        my ( $tag, %attr ) = @$_;
	        
                next if (($tag !~ /^a$/i) && ($tag !~ /^form$/i) && ($tag !~ /^area$/i) && ($tag !~ /^layer$/i) && ($tag !~ /^iframe$/i) && ($tag !~ /^frame$/i));

	        my $attr = join ' ', map { qq[$_="$attr{$_}"] } keys %attr;
	        
	        my $my_links = $HTML::Tagset::linkElements{$tag};
	        $my_links = [$my_links] unless ref $my_links;

		for my $attribute ( @$my_links ) {
			if ( $attr{ $attribute } ) {  # ok tag
		                # Create a URI object
		                
	                	my $u = URI->new_abs( $attr{$attribute},$url );
	                	
				$u =~ s:\%20\%20onMouseDown\=::gi;
				$u =~ s:\%22::g;

				$u =~ s:h[thp]{1,4}\:\/\/:http\:\/\/:i;
				$u =~ s:^ttp\:\/\/:http\:\/\/:i;
				$u =~ s:^http\:\\:http\:\/\/:i;

	                	if (($u =~ /^javascript/i) && ($u =~ /https?:\/\//i)) {
	                		$u =~ s:^javascript.*?\([^\)]*\'?(https?\://[^\'\),]+).*?$:$1:i;
	                	} elsif ($u =~ /^javascript/i) {
	                		next;
	                	} elsif ($u =~ /^mailto/i) {
	                		next;
	                	} elsif ($u =~ /^https\:/i) {
	                		next;
	                	} elsif ($u =~ /^aim\:/i) {
	                		next;
	                	} elsif ($u =~ /^skype\:/i) {
	                		next;
	                	} elsif ($u =~ /^callto\:/i) {
	                		next;
	                	} elsif ($u =~ /^file\:\/\/\//i) {
	                		next;
				} elsif ($u =~ /\@/) {
	                		next;
	                	}
	                	
	                	if ($u =~ /\.\./i) {
	                		$u =~ s:\.\.::;
	                	}
	                	if ($u =~ /\#/i) {
	                		$u =~ s:\#.*?$::;
	                	}

				next if ($u =~ /^$/);
				next if ($u =~ /[\'\(\)]/);

				$linkobject = new URI::URL $u;
				if ($linkobject->host) {
					$linkdomain = $linkobject->host;
					$linkdomain =~ tr/a-z/A-Z/;
					if($linkdomain ne $domain_cap) {
						$test_url = $u;
						$test_url =~ s:(https?\://[^/]+/).*:$1:;
						$test_url .= "/" if ($test_url !~ /\/$/);
				
						if ($test_url =~ /^http/i) {
							$link_cap = $test_url;
							$link_cap =~ tr/a-z/A-Z/;
							if (!$VISITED{$link_cap}) {
								$test_country = 0;
								
								$test_country = &check_country($test_url,$max_count_tentative,\@count_tentative);

								$VISITED{$link_cap} = 1;

								if (defined($config_url_language{$test_country})) {
									$tera_url = $config_url_language{$test_country} . "ajout.php?cle=DeTeCtIvE&url=$test_url&lang=".$test_country;
									my $req3 = new HTTP::Request GET => "$tera_url";
									my $res3 = $ua->request($req3);

									if ($res3->content =~ /^oui$/i) {
										print STDERR "Found link ",$test_country,": ",$test_url,"\n";
									} else {
										print STDERR $test_url," : already in database $test_country\n";
									}
								} elsif (($count_tentative_1 >= $max_count_tentative) && ($count_tentative_2 >= $max_count_tentative)) {
									print STDERR $test_url," : max connexion whois server\n";
								} else {
									print STDERR $test_url," : not a good site\n";
								}
							}
						}

						next;
					}
				}
				
				if (($u =~ /\.mp3/i) || ($u =~ /\.mp4/i)) {
				    $test_url_page = $u;
				    $test_url_page =~ s:[\?\&]PHPSESSID\=[a-z0-9]+\&:\&:i;
				    $test_url_page =~ s:[\?\&]PHPSESSID\=[a-z0-9]+$:\&:i;

				    my $req4 = new HTTP::Request HEAD => "$test_url_page";
				    my $res4 = $ua->request($req4);
				    my $type4 = $res4->content_type;
				    $type4 =~ s:/:\\/:g;
				    $type4 =~ s:\.:\\\.:g;
				    $type4 =~ s:\?:\\\?:g;
				    $type4 =~ s:\+:\\\+:g;

				    if( grep(/$type4/, @mp3_mime_type) ){
					$tera_url = $config_url_language{$select_language} . "ajout_fichier.php?cle=DeTeCtIvE&extension=mp3&title=&description=&links=".urlEncode($test_url_page)."&url=".$my_first_url."&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);
				    
					print STDERR "Found MP3 link : ",$test_url_page,"\n";
				    }

				    if( grep(/$type4/, @mp4_mime_type) ){
					$tera_url = $config_url_language{$select_language} . "ajout_fichier.php?cle=DeTeCtIvE&extension=mp4&title=&description=&links=".urlEncode($test_url_page)."&url=".$my_first_url."&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);

					print STDERR "Found MP4 link : ",$test_url_page,"\n";
				    }
				}

				if ($u =~ /\.pdf/i) {
				    $test_url_page = $u;
				    $test_url_page =~ s:[\?\&]PHPSESSID\=[a-z0-9]+\&:\&:i;
				    $test_url_page =~ s:[\?\&]PHPSESSID\=[a-z0-9]+$:\&:i;

				    my $req4 = new HTTP::Request HEAD => "$test_url_page";
				    my $res4 = $ua->request($req4);
				    my $type4 = $res4->content_type;
				    $type4 =~ s:/:\\/:g;
				    $type4 =~ s:\.:\\\.:g;
				    $type4 =~ s:\?:\\\?:g;
				    $type4 =~ s:\+:\\\+:g;

				    if( grep(/$type4/, @pdf_mime_type) ){
					$tera_url = $config_url_language{$select_language} . "ajout_fichier.php?cle=DeTeCtIvE&extension=pdf&title=&description=&links=".urlEncode($test_url_page)."&url=".$my_first_url."&lang=".$select_language;
					my $req3 = new HTTP::Request GET => "$tera_url";
					my $res3 = $ua->request($req3);
				    
					print STDERR "Found PDF link : ",$test_url_page,"\n";
				    }
				}

				$link_cap = $u;
				$link_cap =~ tr/a-z/A-Z/;
				if (!$VISITED{$link_cap}) {
					$VISITED{$link_cap} = 1;
					push(@links,$u);
				}
			}
		}
	}
	
	while ($content =~ /<object/i) {
		if ($content =~ /<param name=movie value=\"?([^\"> ]+.swf)\"?>/i) {
			$flash_url = $domain . $1;
			$flash_url =~ s:\/\.:\/:;
			
			$link_cap = $flash_url;
			$link_cap =~ tr/a-z/A-Z/;
			if (!$VISITED{$link_cap}) {
				$VISITED{$link_cap} = 1;
				push(@links,$flash_url);

				$tera_url = $config_url_language{$select_language} . "ajout_flash.php?cle=DeTeCtIvE&url=$my_first_url&is_flash=oui&lang=".$select_language;
				my $req3 = new HTTP::Request GET => "$tera_url";
				my $res3 = $ua->request($req3);
			}
		}
		$content =~ s:<object::i;
	}
	
	if($content) {
		$check_email = $domain;
		$check_email =~ s:^https?\://::i;
		$check_email =~ s:\/ *$::i;
		$check_email =~ s:^www\.::i;
		if ($content =~ /([a-z\-\_\.0-9]+\@$check_email)/i) {
			$tera_url = $config_url_language{$select_language} . "ajout_email.php?cle=DeTeCtIvE&url=$my_first_url&email=$1&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}
	}
	
	if ($content) {
		if ($content =~ /< *(FRAME [^>]*)(SRC)="([^"]*)"[^>]*>/is ) {
			$tera_url = $config_url_language{$select_language} . "ajout_frame.php?cle=DeTeCtIvE&url=$my_first_url&is_frame=oui&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);
		}
	}

	if ($content && ($my_first_url eq $url)) {
                if (&check_boutique($content)) {
#                       $tera_url = "http://boutique.test.com/add_boutique.php?cle=DeTeCtIvE&myurl=$my_first_url&lang=".$select_language;
#                       my $req3 = new HTTP::Request GET => "$tera_url";
#                       my $res3 = $ua->request($req3);

			$tera_url = $config_url_language{$select_language} . "ajout_boutique.php?cle=DeTeCtIvE&url=$my_first_url&lang=".$select_language;
			my $req3 = new HTTP::Request GET => "$tera_url";
			my $res3 = $ua->request($req3);

			my $msg = new MIME::Lite
                                    From    =>'paul.personne@test.com',
                                    To      =>'paul.personne@test.com',
                                    Subject =>"Spider France : New shop $select_language found -> $my_first_url",
                                    Type    =>'TEXT',
                                    Data    =>"";
                        $msg -> send;

                        print STDERR "$my_first_url is a shop\n";
                }
        }

}
	
	
sub innerGet {
	local ($type, $url) = @_;
	local ($result, $tmpfile);
	local ($title, $docname);
	local ($description, $doctype, $author, $created, $modified, $add);
	
	if( $url =~ /\/([^\/]+)$/ ) {
		$docname = $1;
	}
#	$tmpfile = "$root_path/tmp/tmpfile.$MIME_EXT{$type}";

	$tmpfile = $url;
	$tmpfile =~ s:https?\:\/\/::gi;
	$tmpfile =~ s:[^A-Z0-9]:_:gi;

	$tmpfile = "$root_path/tmp/".$tmpfile.".$MIME_EXT{$type}";

	if( $type eq "application/msword" && $url !~ /\.doc$/i ) {
		return "";
	} elsif( $type eq "application/vnd.ms-excel" && $url !~ /\.xls$/i ) {
		return "";
	} elsif( $type eq "application/msword" || $type eq "application/vnd.ms-excel") {
		$command = "ldat $tmpfile";
		undef $/;
		open( CMD, "$command |") || die "Cannot check word format\n";
		$line = <CMD>;
		close(CMD);
		if( $type eq "application/msword" ) {
			if( $line =~  /Application: Microsoft Word 8\.0/ ) {
				$type = "application/msword-8";
				$doctype = "Word 8";
			} else {
				$type = "application/msword-6-7";
				$doctype = "Word (other than 8)";
			}
		} else {
			$doctype = "Excel";
		}
		if( $line =~ /Authress: (.*)\n/ ) {
			$author = $1;
		}
		if( $line =~ /Title: (.*)\n/ ) {
			$title = $1;
		}
		if( $line =~ /Created: (.*)\n/ ) {
			$created = $1;
		}
		if( $line =~ /Last saved: (.*)\n/ ) {
			$modified = $1;
		}
		$title = "$docname - ";
		$title .= $title." - " if($title);
		$title = "$doctype document " if( $doctype);
		$description = "$docname" if($docname);
		$description .= " $doctype document " if( $doctype);
		$description .= " - Author: $author" if( $author );
		$description .= " - Created: $created" if( $created );
		$description .= " - Modified: $modified" if( $modified );
	} elsif( $type eq "application/dbf" ) {
		$command = "dbfdump --info --nomemo $tmpfile";
		undef $/;
		open( CMD, "$command |") || die "Cannot check DBF format\n";
		$line = <CMD>;
		close(CMD);
		$line =~ s:File.*?\n::;
		$line =~ s:Header.*?\n::;
		$line =~ s:Record.*?\n::;
		$line =~ s:Field.*?$::s;
		$line =~ s:\n: :g;
		$title = "$docname - DBF file" if($docname);
		$description = "$docname" if($docname);
		$description .= " DBF document ";
		$description .= $line;
	}

	$command = $MIME_TYPES{$type};
	$command =~ s:__ROBOT_FILE__:$tmpfile:;

	undef $/;	
	open(IN, "$command | ") || die "Cannot open tmpfile\n";
	$result = <IN>;	
	close(IN);
	unlink $tmpfile;
	if( $result !~ /<HEAD[^>]*>/i ) {
		$add = "<META NAME=\"Author\" CONTENT=\"$author\">\n" if ($author);
		$add .= "<META NAME=\"Description\" CONTENT=\"$description\">\n" if ($description);
		$add .= "<TITLE[^>]*>$title</TITLE>\n";
		$result = "<HEAD>\n$add</HEAD>\n".$result;
	}

	return $result;
}

sub do_maj {
	local ($line) = @_;

	return HTML::Entities::decode($line);
}

sub main::urlEncode {
    my ($string) = @_;
    $string =~ s/(\W)/"%" . unpack("H2", $1)/ge;
    #$string# =~ tr/.//;
    return $string;
 }

 sub main::urlDecode {
    my ($string) = @_;
    $string =~ tr/+/ /;
    $string =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    
    return $string;
}

sub whois {
	my ($domain, $server) = @_;
	my $returnString="";
	
	# ouverture du port WHOIS 43 
	my $remote = new IO::Socket::INET( 
		Proto => "tcp",
		PeerAddr => "$server",
		PeerPort => "whois(43)",
	);
#	) or die "Cannot connect to whois server...\n";
	
	# interroge le serveur WHOIS 
	if ($remote) {
	    $remote->autoflush(1);
	    print $remote "$domain\n" . $BLANK;
	    while ( <$remote> ) {
		$returnString.=$_;
	    }
	    close $remote;
	}

	#retourne le r�sultat
	$returnString;
}


