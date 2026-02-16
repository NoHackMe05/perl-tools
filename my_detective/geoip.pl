#!/usr/bin/perl
#
#


use Geo::IPfree qw(LookUp);

my ($country, $country_name) = LookUp("www.batipass.com");

print "Batipass : $country,$country_name\n";

my ($country, $country_name) = LookUp("www.test.net");

print "ACR : $country,$country_name\n";

my ($country, $country_name) = LookUp("uk.french-spider.com");

print "UK FS : $country,$country_name\n";

my ($country, $country_name) = LookUp("www.microsoft.com");

print "Microsoft : $country,$country_name\n";

my ($country, $country_name) = LookUp("www.belfasttelegraph.co.uk");

print "Belfast : $country,$country_name\n";

my ($country, $country_name) = LookUp("www.test.com");

print "ACR Ing : $country,$country_name\n";

my ($country, $country_name) = LookUp("www.bati-search.com");

print "Batisearch : $country,$country_name\n";

my ($country, $country_name) = LookUp("10.142.207.18");

print "10.142.207.18 : $country,$country_name\n";

my ($country, $country_name) = LookUp("41.202.100.201");

print "41.202.100.201 : $country,$country_name\n";
