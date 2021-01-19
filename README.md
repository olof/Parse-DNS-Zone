Parse::DNS::Zone parses a Zonefile, defining a zone in a domain
name hierarchy. The module then offers an object oriented way of
getting values out of the zone.

Validation of RRs or RR-names are out of the scope of this
module.

# Synopsis

Consider the following zonefile, let's call it `db.example.org`:

```zone
@             3600  IN  SOA  ns1.example.net. hostmaster.example.net. (
                                 2020121120
                                 7200
                                 3600
                                 1209600
                                 3600
                             )

              86400 IN  NS   ns1.example.net.
              86400 IN  NS   ns2.example.net.

              86400 IN  A    192.0.2.34
	      86400 IN  MX   0 .
www           86400 IN  A    192.0.2.34
```

```perl
use 5.020;
use Parse::DNS::Zone;

my $pdz = Parse::DNS::Zone->new(
	zonefile=>'db.example.org',
	origin=>'example.org.',
);

# Get the A record of www.example.org:
say "A ", $pdz->get_rdata(name=>'www', rr=>'A');

# Get example.org's MX record:
say "MX ", $pdz->get_rdata(name=>'@', rr=>'MX');

# Get example.org's NS records:
say "NS ", join(", ", $pdz->get_rdata(name=>'@', rr=>'NS'));
# or only the first:
say "NS ", scalar $pdz->get_rdata(name=>'@', rr=>'NS');
# or only the second (counting from 0):
say "NS ", scalar $pdz->get_rdata(name=>'@', rr=>'NS', n=>1);

# Getting SOA values
say "mname=", $pdz->get_mname();
say "rname=", $pdz->get_rname();
say "serial=", $pdz->get_serial();
```

# Installation

    perl Makefile.PL
    make
    make test
    make install

(Note that the last step, `make install`, may require you to have
root permissions. But avoid running it as root unless you trust
me for some weird reason. There are various solutions, but one of
the simpler is `local::lib`, this sets up a user local perl
module install path in your home directory.)

# Status and limitations

This module is tested against simple Bind9 and nsd3 zones, please
report success or failures on other nameds, with similar RFC1034
format. Patches/suggestions to the test suite for edge cases are
especially appreciated, regardless if the module already handles
it or not.

A design goal of this module is to have minimum knowledge of the
RRTYPEs available, so that it does not need to kept up to date
with further extensions of the DNS protocol.

The module is not designed to handle very large zones.

# Availability

Latest stable version is available on CPAN. Current development
version is available on https://github.com/olof/Parse-DNS-Zone.

## Version numbering

Up until version `0.60`, the version numbers should be intepreted
as floating point numbers, and 0.5 is higher than 0.42. This is
true for later versions as well, but I will make sure the
ordering is correct also for lexical sorting (by appending
zeroes). I.e. a future version, 0.99 will not be followed by 1,
but 1.00). Doing otherwise would just make it harder to
distribute this software in systems that rely on lexical sorting
of versions.

# Closing remakrs

Have fun with DNS.
