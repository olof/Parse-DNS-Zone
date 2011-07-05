#!/usr/bin/perl 
use strict;
use warnings;
use Test::More tests => 41;

BEGIN { use_ok('Parse::DNS::Zone') }

my %zone_simple = (
	file=>'t/data/db.simple',
	origin=>'example.com.',
	mname=>'ns1.example.com.',
	rname=>'hostmaster.example.com.',
	serial=>1234567890,
	refresh=>86400,
	retry=>3600,
	expire=>3600000,
	minimum=>14400,
	names => {
		'@' => [qw/SOA NS A MX/],
		ns1 => [qw/A/],
		ns2 => [qw/A/],
		mail1 => [qw/A/],
		mail2 => [qw/A/],
		'test' => [qw/A AAAA/],
		'test-cname' => [qw/CNAME/],
		'test-reccname' => [qw/CNAME/],
		'test-dupes' => [qw/A/],
		'test-class' => [qw/A/],
		'test-ttl' => [qw/A/],
		'test-ttlclass' => [qw/A/],
		'test-ttlclassr' => [qw/A/],
		'test-include' => [qw/A AAAA/],
		'test-origapp' => [qw/CNAME/],
	},
);

$zone_simple{size} = int(keys %{$zone_simple{names}});

if(! -r $zone_simple{file}) {
	BAIL_OUT("$zone_simple{file} does not exist");
}

my $zone = Parse::DNS::Zone->new(
	zonefile=>$zone_simple{file},
	origin=>$zone_simple{origin},
);

is(
	$zone->get_rdata(name=>'@', rr=>'A'),
	$zone->get_rdata(name=>$zone_simple{origin}, rr=>'A'),
	"@ should translate to origin"
);

is(
	$zone->get_rdata(name=>'@', rr=>'NS'), 
	'ns1.example.com.', 
	"get NS rdata, ns1"
);

is(
	$zone->get_rdata(name=>'@', rr=>'NS', n=>1), 
	'ns2.example.com.', 
	"get NS rdata, ns2"
);

is(
	$zone->get_rdata(name=>'@', rr=>'NS', n=>0), 
	scalar $zone->get_rdata(name=>'@', rr=>'NS'),
	"get NS rr dupe, 0 and implicit is equal"
);

is(
	$zone->get_dupes(name=>'@', rr=>'NS'),
	2,
	"get number of duplicate rrs with get_dupes()"
);

is(
	$zone->get_rdata(name=>'@', rr=>'A'), 
	'127.0.0.1', 
	'get A rr data'
);

is(
	$zone->get_rdata(name=>'@', rr=>'MX'), 
	'10 mail1.example.com.', 
	'get MX rdata with whitespace'
);

is(
	int($zone->get_names),
	$zone_simple{size},
	"expected number of names in zone"
);

ok($zone->exists('NS1.EXAMPLE.COM.'), "Case insensitivity 1");
ok($zone->exists('NS1.ExamplE.COM.'), "Case insensitivity 2");
is(
	$zone->get_rdata(name=>'NS1.ExaMplE.coM.', rr=>'a'),
	$zone->get_rdata(name=>'ns1.example.com.', rr=>'A'),
	'Case insensitivity 3',
);

ok($zone->exists('test'), "label test should exist");
ok($zone->exists('test.example.com.'), "test.example.com. should exist");
ok(! $zone->exists('.'), "root (.) should not exist in zone");
ok(! $zone->exists('fail'), "non existent domain should not exist");
ok(
	! $zone->exists('fail.example.com.'), 
	"non existent domain should not exist (fqdn)"
);

ok(
	! $zone->get_rdata(name=>'example.com.', rr=>'TXT'), 
	'commented out rr should not exist'
);

is(
	int($zone->get_rrs('test')),
	int(@{$zone_simple{names}->{test}}),
	"expected number of RRs for test"
);

is(
	$zone->get_rdata(name=>'test', rr=>'A'), 
	'192.168.0.1', 
	'get A rr data'
);

is(
	$zone->get_rdata(name=>'test', rr=>'AAAA'), 
	'::1', 
	'get AAAA rr data for test'
);

is(
	$zone->get_rdata(name=>'test-include', rr=>'A'), 
	'192.168.128.1', 
	'get A rr data from included file'
);

is(
	$zone->get_rdata(name=>'test-include', rr=>'AAAA'), 
	'::1', 
	'get AAAA rr data from included file'
);

is(
	$zone->get_dupes(name=>'test-dupes', rr=>'A'),
	3,
	"expected number of dupes for test-dupes"
);

{ 
	my @test = $zone->get_rdata(name=>'test-dupes', rr=>'A'); 
	is(
		int @test,
		3,
		'expected list from get_rdata(test-dupes) '.(@test)
	);
}

is($zone->get_mname, $zone_simple{mname}, "expected MNAME");
is($zone->get_rname, $zone_simple{rname}, "expected RNAME");

{
	my($rname) = $zone_simple{rname};
	$rname=~s/\./@/;
	is(
		$zone->get_rname(parse=>1), 
		$rname, 
		"expected RNAME (with parsing)"
	);
}

is($zone->get_serial, $zone_simple{serial}, "SOA serial");
is($zone->get_refresh, $zone_simple{refresh}, "SOA refresh");
is($zone->get_retry, $zone_simple{retry}, "SOA retry");
is($zone->get_expire, $zone_simple{expire}, "SOA expire");
is($zone->get_minimum, $zone_simple{minimum}, "SOA minimum");

is(
	$zone->get_rdata(name=>'test-class', rr=>'A', field=>'class'), 
	'IN', 'Extract class data from rr'
);

is(
	$zone->get_rdata(name=>'test-ttl', rr=>'A', field=>'ttl'), 
	'400', 'Extract ttl data from rr'
);

is(
	$zone->get_rdata(name=>'test-ttlclass', rr=>'A', field=>'class'), 
	'IN', 'Extract class data from rr with class and ttl'
);

is(
	$zone->get_rdata(name=>'test-ttlclass', rr=>'A', field=>'ttl'), 
	'400', 'Extract ttl data from rr with class and ttl'
);

is(
	$zone->get_rdata(name=>'test-ttlclassr', rr=>'A', field=>'class'), 
	'IN', 'Extract class data from rr with class and ttl (reversed)'
);

is(
	$zone->get_rdata(name=>'test-ttlclassr', rr=>'A', field=>'ttl'), 
	'400', 'Extract ttl data from rr with class and ttl (reversed)'
);

is(
	$zone->get_rdata(name=>'test-origapp', rr=>'CNAME', field=>'rdata'),
	'test', 'Do not append origin to RDATA if not told to do so'
);

$zone = Parse::DNS::Zone->new(
	zonefile=>$zone_simple{file},
	origin=>$zone_simple{origin},
	append_origin=>1,
);

is(
	$zone->get_rdata(name=>'test-origapp', rr=>'CNAME', field=>'rdata'),
	"test.$zone_simple{origin}", 'Append origin to RDATA if told to do so'
);

