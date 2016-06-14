#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;

BEGIN { use_ok('Parse::DNS::Zone') }

my %zone_domainkey = (
	file=>'t/data/db.domainkey',
	origin=>'example.com.',
	mname=>'ns1.example.com.',
	rname=>'hostmaster.example.com.',
	serial=>1234567890,
	refresh=>86400,
	retry=>3600,
	expire=>3600000,
	minimum=>14400,
	names => {
		'@' => [qw/SOA TXT/],
		'dkim-multiline' => [qw/TXT/],
		'dkim-singleline' => [qw/TXT/],
		'dkim-semicolons' => [qw/TXT/],
	},
);

$zone_domainkey{size} = int(keys %{$zone_domainkey{names}});

if(! -r $zone_domainkey{file}) {
	BAIL_OUT("$zone_domainkey{file} does not exist");
}

my $zone = Parse::DNS::Zone->new(
	zonefile=>$zone_domainkey{file},
	origin=>$zone_domainkey{origin},
);

is(
	int($zone->get_names),
	$zone_domainkey{size},
	"expected number of names in zone"
);

is(
	$zone->get_rdata(name=>'@', rr=>'TXT'),
	$zone->get_rdata(name=>$zone_domainkey{origin}, rr=>'TXT'),
	"@ should translate to origin"
);

ok(
	! $zone->get_rdata(name=>'comment.example.com.', rr=>'TXT'),
	'commented out rr should not exist'
);

is(
	$zone->get_rdata(name=>'dk-multiline.example.com.', rr=>'TXT'),
	'v=DKIM1 descr=multiline foo=bar',
	"Multiline TXT record is not complete"
);

is(
	$zone->get_rdata(name=>'dk-singleline.example.com.', rr=>'TXT'),
	'"v=DKIM1\; descr=singleline\; fizz=buzz\;"',
	"Singleline TXT record is not complete"
);

is(
	$zone->get_rdata(name=>'dk-semicolon.example.com.', rr=>'TXT'),
	'"v=DKIM1; descr=semicolons; fizz=buzz;"',
	"Semicolon TXT record is not complete"
);

