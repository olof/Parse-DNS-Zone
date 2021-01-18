Parse::DNS::Zone parses a Zonefile, defining a zone in a domain
name hierarchy. The module then offers an object oriented way of
getting values out of the zone.

Validation of RRs or RR-names are out of the scope of this
module.

# Installation

    perl Makefile.PL
    make
    make test
    make install

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
