#!/usr/bin/perl
#
#
#

use Encode;

$url = '';
$dmoz_url = '';
while (<>) {
	s:\r::g;
	chop();

	if (/<ExternalPage about=\"([^\"]+)\">/i) {
		$url = $1;
	} elsif (/<\/ExternalPage>/i) {
		$url = '';
		$dmoz_url = '';
	} elsif (/<topic>(Top\/World\/Français\/.*?)<\/topic>/i) {
		$dmoz_url = $1;

		if ($dmoz_url =~ /\xC3/) {
                	$dmoz_url = decode_utf8($dmoz_url);
               	}

		$dmoz_url =~ s:^Top:http\:\/\/www\.dmoz\.org:gi;

		if ($url && $dmoz_url) {
			print "$dmoz_url\t$url\n";
		}
	}
}
